import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../models/device_model.dart';

/// Mock BLE service: simulates scan, connect, read/write/notify
class BleService {
  final Random _rand = Random();
  Timer? _scanTimer;
  final _controller = StreamController<DeviceModel>.broadcast();
  final Map<String, StreamController<List<int>>> _notifyControllers = {};

  /// Simulate scanning — emits found devices on [Stream]
  Stream<DeviceModel> startScan() {
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(Duration(milliseconds: 700), (_) {
      final dev = DeviceModel(
        id: 'BLE-${_rand.nextInt(1000)}',
        name: 'Arvyax-BLE-${_rand.nextInt(99)}',
        isBle: true,
        rssi: -30 - _rand.nextInt(70),
      );
      _controller.add(dev);
    });
    return _controller.stream;
  }

  void stopScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
  }

  /// Simulate connect with a delay and random chance of failure
  Future<bool> connect(DeviceModel device) async {
    await Future.delayed(Duration(milliseconds: 800 + _rand.nextInt(700)));
    final success = _rand.nextDouble() > 0.12; // 88% success
    if (success) {
      // Create notify stream
      _notifyControllers[device.id] = StreamController<List<int>>.broadcast();
      // Start emitting notifications
      Timer.periodic(Duration(seconds: 1), (t) {
        if (!_notifyControllers.containsKey(device.id) || _notifyControllers[device.id]!.isClosed) {
          t.cancel();
          return;
        }
        // Random sensor-like payload
        final payload = utf8.encode('DATA:${_rand.nextInt(200)}');
        _notifyControllers[device.id]!.add(payload);
      });
    }
    return success;
  }

  Future<void> disconnect(DeviceModel device) async {
    await Future.delayed(Duration(milliseconds: 200));
    await _notifyControllers[device.id]?.close();
    _notifyControllers.remove(device.id);
  }

  /// Simulate GATT read
  Future<List<int>> read(DeviceModel device, String characteristic) async {
    await Future.delayed(Duration(milliseconds: 300 + _rand.nextInt(400)));
    return utf8.encode('READ:${_rand.nextInt(999)}');
  }

  /// Simulate GATT write
  Future<bool> write(DeviceModel device, String characteristic, List<int> data) async {
    await Future.delayed(Duration(milliseconds: 200 + _rand.nextInt(300)));
    // pretend success
    return true;
  }

  /// Subscribe to notifications for a device
  Stream<List<int>> subscribeNotifications(DeviceModel device) {
    return _notifyControllers.putIfAbsent(device.id, () => StreamController<List<int>>.broadcast()).stream;
  }
}