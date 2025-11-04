import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/bluetooth/ble_service.dart';
import '../core/bluetooth/classic_service.dart';
import '../core/bluetooth/connection_wrapper.dart';
import '../core/models/device_model.dart';
import '../core/utils/retry_backoff.dart';
import '../constants.dart';

class DeviceViewModel extends GetxController {
  final BleService bleService;
  final ClassicService classicService;
  final ConnectionWrapper connectionWrapper;
  final SharedPreferences prefs;

  DeviceViewModel({
    required this.bleService,
    required this.classicService,
    required this.connectionWrapper,
    required this.prefs,
  });

  final RxList<DeviceModel> devices = <DeviceModel>[].obs;
  final Rxn<DeviceModel> connectedDevice = Rxn<DeviceModel>();
  final RxString lastData = ''.obs;
  final RxString status = 'disconnected'.obs;
  final RxList<String> logs = <String>[].obs;
  final RxBool isScanning = false.obs;

  StreamSubscription? _bleScanSub;
  StreamSubscription? _classicScanSub;
  StreamSubscription? _notifySub;
  StreamSubscription? _classicStreamSub;
  StreamSubscription? _wrapperLogSub;

  @override
  void onInit() {
    super.onInit();
    // Listen to wrapper logs
    _wrapperLogSub = connectionWrapper.subscribeLogs().listen((e) {
      logs.insert(0, e);
      // keep small
      if (logs.length > 200) logs.removeRange(200, logs.length);
    });

    // Auto-connect to last device if exists
    final last = prefs.getString(prefsLastDeviceKey);
    if (last != null) {
      // We persisted toString earlier. This is a simple demo; in a real app you'd store structured JSON.
      logs.insert(0, 'Found last connected device string: $last');
      // In this mock, do not auto-found exact id — instead auto-scan and auto-connect to first discovered device after scan.
      Future.delayed(Duration(milliseconds: 600), () {
        startScan(autoConnect: true);
      });
    }
  }

  @override
  void onClose() {
    _bleScanSub?.cancel();
    _classicScanSub?.cancel();
    _notifySub?.cancel();
    _classicStreamSub?.cancel();
    _wrapperLogSub?.cancel();
    super.onClose();
  }

  void startScan({bool autoConnect = false}) {
    devices.clear();
    isScanning.value = true;
    logs.insert(0, 'Scan started');

    _bleScanSub = bleService.startScan().listen((d) {
      final exists = devices.any((e) => e.id == d.id);
      if (!exists) devices.add(d);
      if (autoConnect && connectedDevice.value == null && d.name.contains('Arvyax-BLE')) {
        // auto-connect to the first BLE Arvyax
        Future.delayed(Duration(milliseconds: 500), () => connect(d));
      }
    });

    _classicScanSub = classicService.startScan().listen((d) {
      final exists = devices.any((e) => e.id == d.id);
      if (!exists) devices.add(d);
      if (autoConnect && connectedDevice.value == null && d.name.contains('Arvyax-SPP')) {
        Future.delayed(Duration(milliseconds: 500), () => connect(d));
      }
    });

    // stop scan after some time
    Future.delayed(Duration(seconds: 6), () {
      stopScan();
    });
  }

  void stopScan() {
    bleService.stopScan();
    classicService.stopScan();
    _bleScanSub?.cancel();
    _classicScanSub?.cancel();
    isScanning.value = false;
    logs.insert(0, 'Scan stopped');
  }

  Future<void> connect(DeviceModel device) async {
    stopScan();
    status.value = 'connecting';
    logs.insert(0, 'Connecting to ${device.name}');
    await connectionWrapper.connect(device);
    if (connectionWrapper.state == ConnState.connected) {
      connectedDevice.value = device;
      status.value = 'connected';
      // Subscribe to data streams
      _notifySub?.cancel();
      _classicStreamSub?.cancel();
      if (device.isBle) {
        _notifySub = bleService.subscribeNotifications(device).listen((bytes) {
          final s = utf8.decode(bytes);
          lastData.value = s;
          logs.insert(0, 'BLE notify: $s');
        }, onDone: () {
          connectionWrapper.onConnectionDropped();
        }, onError: (_) {
          connectionWrapper.onConnectionDropped();
        });
      } else {
        _classicStreamSub = classicService.stream(device).listen((s) {
          lastData.value = s;
          logs.insert(0, 'SPP data: $s');
        }, onDone: () {
          connectionWrapper.onConnectionDropped();
        }, onError: (_) {
          connectionWrapper.onConnectionDropped();
        });
      }
    } else {
      status.value = 'disconnected';
      logs.insert(0, 'Failed to connect to ${device.name}');
    }
  }

  Future<void> disconnect() async {
    logs.insert(0, 'Manual disconnect requested');
    await connectionWrapper.disconnect(manual: true);
    connectedDevice.value = null;
    status.value = 'disconnected';
    _notifySub?.cancel();
    _classicStreamSub?.cancel();
  }

  Future<void> sendCommand(String payload) async {
    final dev = connectedDevice.value;
    if (dev == null) {
      logs.insert(0, 'No connected device to send');
      return;
    }
    logs.insert(0, 'Sending: $payload');
    if (dev.isBle) {
      await bleService.write(dev, 'char-uuid', utf8.encode(payload));
      logs.insert(0, 'Wrote to BLE: $payload');
    } else {
      await classicService.send(dev, payload);
      logs.insert(0, 'Sent via Classic: $payload');
    }
  }
}