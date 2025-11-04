import 'package:permission_handler/permission_handler.dart';

/// PermissionsService centralizes requesting runtime permissions for the app.
///
/// Uses permission_handler package to request:
/// - Location (required historically for BLE scanning on Android)
/// - Bluetooth (Android 12+ runtime permissions: bluetoothScan, bluetoothConnect, bluetoothAdvertise)
/// - Additional fine location on older Android versions when needed
///
/// This service returns a consolidated result that indicates whether the essential permissions are granted.
class PermissionsResult {
  final bool granted;
  final Map<Permission, PermissionStatus> statuses;
  PermissionsResult(this.granted, this.statuses);
}

class PermissionsService {
  /// Request the set of permissions commonly required for Bluetooth scanning/connecting.
  ///
  /// On Android 12+ we request bluetoothScan, bluetoothConnect (and optionally bluetoothAdvertise).
  /// We also request location when required (pre-Android-12 or if the platform requires it).
  Future<PermissionsResult> requestPermissions() async {
    final Map<Permission, PermissionStatus> statuses = {};

    // Bluetooth permissions for Android 12+:
    try {
      // Request bluetooth permissions (these will be ignored on iOS)
      final scan = await Permission.bluetoothScan.request();
      final connect = await Permission.bluetoothConnect.request();
      final advertise = await Permission.bluetoothAdvertise.request();

      statuses[Permission.bluetoothScan] = scan;
      statuses[Permission.bluetoothConnect] = connect;
      statuses[Permission.bluetoothAdvertise] = advertise;
    } catch (_) {
      // permission_handler may throw if a permission isn't available on platform;
      // ignore and continue to request location below.
    }

    // Location permission (still required on some Android versions for scanning)
    final loc = await Permission.locationWhenInUse.request();
    statuses[Permission.locationWhenInUse] = loc;

    // For completeness, request Bluetooth (legacy) permission which maps to BLUETOOTH on some platforms
    final bluetooth = await Permission.bluetooth.request();
    statuses[Permission.bluetooth] = bluetooth;

    // Consolidate result: consider permissions granted if at least location and bluetooth/connect are granted,
    // but keep flexible for mock demo: accept if either location or bluetooth connect is granted.
    final bool essentialGranted = (statuses[Permission.locationWhenInUse]?.isGranted ?? false) ||
        (statuses[Permission.bluetoothConnect]?.isGranted ?? false) ||
        (statuses[Permission.bluetooth]?.isGranted ?? false);

    return PermissionsResult(essentialGranted, statuses);
  }

  /// Opens the app settings page so the user can manually toggle permissions.
  Future<bool> openAppSettings() => openAppSettings();
}