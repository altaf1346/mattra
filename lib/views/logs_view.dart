import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodels/device_viewmodel.dart';

class LogsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = Get.find<DeviceViewModel>();
    return Scaffold(
      appBar: AppBar(title: Text('Connection Logs')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() {
          final logs = vm.logs;
          if (logs.isEmpty) {
            return Center(child: Text('No logs yet.'));
          }
          return ListView.separated(
            itemCount: logs.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (_, i) => Text(logs[i]),
          );
        }),
      ),
    );
  }
}