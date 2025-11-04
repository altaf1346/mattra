import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../core/models/device_model.dart';
import '../viewmodels/device_viewmodel.dart';
import 'widgets/connection_status.dart';

class DeviceDetailView extends StatelessWidget {
  final DeviceModel device;

  const DeviceDetailView({Key? key, required this.device}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<DeviceViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: [
          IconButton(
            icon: Icon(Icons.link_off),
            onPressed: vm.connectedDevice.value != null ? vm.disconnect : null,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ConnectionStatus(stateText: vm.status.value),
            SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text(device.name),
                subtitle: Text('ID: ${device.id}\n${device.isBle ? "BLE (GATT)" : "Classic (SPP)"}'),
                isThreeLine: true,
                trailing: ElevatedButton(
                  child: Text(vm.connectedDevice.value?.id == device.id ? 'Connected' : 'Connect'),
                  onPressed: () => vm.connect(device),
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Live Data', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(vm.lastData.value.isEmpty ? 'No data yet' : vm.lastData.value),
                    ),
                    SizedBox(height: 12),
                    Text('Commands', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    CommandPanel(device: device),
                    SizedBox(height: 12),
                    Text('Recent Logs', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Expanded(
                      child: Obx(() {
                        final logs = vm.logs;
                        return ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (_, i) => Text(logs[i], style: TextStyle(fontSize: 12)),
                        );
                      }),
                    )
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class CommandPanel extends StatefulWidget {
  final DeviceModel device;
  CommandPanel({required this.device});

  @override
  _CommandPanelState createState() => _CommandPanelState();
}

class _CommandPanelState extends State<CommandPanel> {
  final TextEditingController _ctrl = TextEditingController(text: 'PING');

  @override
  Widget build(BuildContext context) {
    final vm = Get.find<DeviceViewModel>();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(border: OutlineInputBorder(), isDense: true),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          child: Text('Send'),
          onPressed: () {
            vm.sendCommand(_ctrl.text);
          },
        )
      ],
    );
  }
}