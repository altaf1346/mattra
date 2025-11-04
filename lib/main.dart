import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mattra/core/utils/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'core/bluetooth/ble_service.dart';
import 'core/bluetooth/classic_service.dart';
import 'core/bluetooth/connection_wrapper.dart';
// import 'core/utils/permissions_service.dart';
import 'viewmodels/device_viewmodel.dart';
import 'views/scan_view.dart';
import 'views/logs_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Initialize services and wrapper (mock)
  final bleService = BleService();
  final classicService = ClassicService();
  final connectionWrapper = ConnectionWrapper(
    bleService: bleService,
    classicService: classicService,
    prefs: prefs,
  );

  // Device ViewModel (GetX)
  final deviceViewModel = DeviceViewModel(
    bleService: bleService,
    classicService: classicService,
    connectionWrapper: connectionWrapper,
    prefs: prefs,
  );

  runApp(MyApp(deviceViewModel: deviceViewModel));
}

class MyApp extends StatelessWidget {
  final DeviceViewModel deviceViewModel;

  const MyApp({Key? key, required this.deviceViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Arvyax Smart Mat (Mock)',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeShell(deviceViewModel: deviceViewModel),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeShell extends StatefulWidget {
  final DeviceViewModel deviceViewModel;

  const HomeShell({Key? key, required this.deviceViewModel}) : super(key: key);

  @override
  _HomeShellState createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final PermissionsService _perm = PermissionsService();

  @override
  void initState() {
    super.initState();
    // Register the controller in GetX dependency system
    Get.put(widget.deviceViewModel);

    // Request permissions on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
    });
  }

  Future<void> _checkAndRequestPermissions() async {
    final result = await _perm.requestPermissions();
    if (!result.granted) {
      // Show a dialog explaining why permissions are needed with action to open app settings
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AlertDialog(
              title: Text('Permissions required'),
              content: Text(
                'This app simulates Bluetooth device discovery and requires Location and Bluetooth permissions to demonstrate permission flows. '
                    'Please grant the permissions in Settings if you previously denied them.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Dismiss'),
                ),
                TextButton(
                  onPressed: () {
                    _perm.openAppSettings();
                    Navigator.of(context).pop();
                  },
                  child: Text('Open Settings'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Arvyax Smart Mat — Mock'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => Get.to(() => LogsView()),
            tooltip: 'Logs',
          ),
        ],
      ),
      body: ScanView(),
    );
  }
}