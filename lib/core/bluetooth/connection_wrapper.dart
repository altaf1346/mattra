import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/device_model.dart';
import '../utils/retry_backoff.dart';
import 'ble_service.dart';
import 'classic_service.dart';

enum ConnState { disconnected, scanning, connecting, connected, reconnecting }

class ConnectionWrapper {
  final BleService bleService;
  final ClassicService classicService;
  final SharedPreferences prefs;

  final RetryBackoff _backoff = RetryBackoff();
  final StreamController<String> _logController = StreamController.broadcast();

  DeviceModel? _current;
  ConnState _state = ConnState.disconnected;
  int _attempt = 0;
  Timer? _reconnectTimer;

  ConnectionWrapper({
    required this.bleService,
    required this.classicService,
    required this.prefs,
  });

  ConnState get state => _state;
  DeviceModel? get current => _current;
  Stream<String> get logs => _logController.stream;

  void _log(String s) {
    _logController.add('${DateTime.now().toIso8601String()} $s');
  }

  Future<void> connect(DeviceModel device) async {
    _reconnectTimer?.cancel();
    _current = device;
    _setState(ConnState.connecting);
    _log('Attempting connect to ${device.name} (${device.id})');

    final success = await (device.isBle ? bleService.connect(device) : classicService.connect(device));
    if (success) {
      _setState(ConnState.connected);
      _attempt = 0;
      _log('Connected to ${device.name}');
      // persist last device
      prefs.setString('last_connected_device', device.toString());
    } else {
      _log('Connect failed to ${device.name}');
      _handleDisconnect(shouldReconnect: true);
    }
  }

  Future<void> disconnect({bool manual = false}) async {
    _reconnectTimer?.cancel();
    if (_current != null) {
      _log('Disconnecting ${_current!.name}${manual ? ' (manual)' : ''}');
      await ( _current!.isBle ? bleService.disconnect(_current!) : classicService.disconnect(_current!));
    }
    _current = null;
    _setState(ConnState.disconnected);
    if (!manual) {
      // auto-reconnect was not requested
      prefs.remove('last_connected_device');
    }
  }

  void _setState(ConnState s) {
    _state = s;
    _log('State => $s');
  }

  void _handleDisconnect({bool shouldReconnect = true}) {
    if (_current == null) {
      _setState(ConnState.disconnected);
      return;
    }
    _setState(ConnState.reconnecting);
    _attempt++;
    if (_attempt > _backoff.maxRetries) {
      _log('Exceeded max retries for ${_current!.name}. Giving up.');
      _setState(ConnState.disconnected);
      _current = null;
      prefs.remove('last_connected_device');
      return;
    }
    final delay = _backoff.getDelay(_attempt - 1);
    _log('Scheduling reconnect #$_attempt in ${delay.inSeconds}s');
    _reconnectTimer = Timer(delay, () {
      if (_current == null) return;
      connect(_current!);
    });
  }

  /// Called when underlying stream ends or connection drops unexpectedly.
  void onConnectionDropped() {
    _log('Underlying connection dropped for ${_current?.name}');
    _handleDisconnect(shouldReconnect: true);
  }

  Stream<String> subscribeLogs() => logs;
}