import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../models/device_model.dart';

/// Mock Classic Bluetooth (SPP) service — simulates scans, connect, streaming IO
class ClassicService {
  final Random _rand = Random();
  Timer? _scanTimer;
  final _controller = StreamController<DeviceModel>.broadcast();
  final Map<String, StreamController<String>> _streams = {};

  Stream<DeviceModel> startScan() {
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(Duration(milliseconds: 900), (_) {
      final dev = DeviceModel(
        id: 'CLASSIC-${_rand.nextInt(1000)}',
        name: 'Arvyax-SPP-${_rand.nextInt(99)}',
        isBle: false,
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

  Future<bool> connect(DeviceModel device) async {
    await Future.delayed(Duration(milliseconds: 900 + _rand.nextInt(600)));
    final success = _rand.nextDouble() > 0.15; // 85% success
    if (success) {
      _streams[device.id] = StreamController<String>.broadcast();
      Timer.periodic(Duration(seconds: 2), (t) {
        if (!_streams.containsKey(device.id) || _streams[device.id]!.isClosed) {
          t.cancel();
          return;
        }
        _streams[device.id]!.add('SPP:${_rand.nextInt(1000)}');
      });
    }
    return success;
  }

  Future<void> disconnect(DeviceModel device) async {
    await Future.delayed(Duration(milliseconds: 200));
    await _streams[device.id]?.close();
    _streams.remove(device.id);
  }

  Future<bool> send(DeviceModel device, String message) async {
    await Future.delayed(Duration(milliseconds: 200 + _rand.nextInt(300)));
    // echo back a response after a delay
    Future.delayed(Duration(milliseconds: 400 + _rand.nextInt(400)), () {
      _streams[device.id]?.add('ECHO:${message}');
    });
    return true;
  }

  Stream<String> stream(DeviceModel device) {
    return _streams.putIfAbsent(device.id, () => StreamController<String>.broadcast()).stream;
  }
}