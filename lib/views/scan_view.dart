import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodels/device_viewmodel.dart';
import 'device_detail_view.dart';
import 'widgets/connection_status.dart';

class ScanView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Get.find<DeviceViewModel>();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Obx(() => ConnectionStatus(stateText: vm.status.value)),
          SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                icon: vm.isScanning.value ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Icon(Icons.search),
                label: Text(vm.isScanning.value ? 'Scanning...' : 'Scan'),
                onPressed: vm.isScanning.value ? null : () => vm.startScan(),
              ),
              SizedBox(width: 8),
              OutlinedButton(
                child: Text('Stop'),
                onPressed: vm.isScanning.value ? vm.stopScan : null,
              ),
              Spacer(),
              ElevatedButton.icon(
                icon: Icon(Icons.device_hub),
                label: Text('View Logs'),
                onPressed: () => Get.toNamed('/logs', arguments: vm),
              )
            ],
          ),
          SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final devices = vm.devices;
              if (devices.isEmpty) {
                return Center(child: Text('No devices found yet. Tap Scan to simulate discovery.'));
              }
              return ListView.separated(
                itemCount: devices.length,
                separatorBuilder: (_, __) => Divider(),
                itemBuilder: (_, i) {
                  final d = devices[i];
                  return ListTile(
                    title: Text(d.name),
                    subtitle: Text('${d.id} • ${d.rssi} dBm • ${d.isBle ? 'BLE' : 'Classic'}'),
                    trailing: ElevatedButton(
                      child: Text('Connect'),
                      onPressed: () => Get.to(() => DeviceDetailView(device: d)),
                    ),
                    leading: Icon(d.isBle ? Icons.bluetooth_searching : Icons.bluetooth),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}