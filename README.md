```markdown
# Arvyax Smart Mat — Flutter Mock (Internship Prototype)

This Flutter prototype simulates connecting to a smart yoga mat (ESP32) over Classic Bluetooth (SPP) and BLE (GATT) using mock logic — no real hardware is required. It's built to demonstrate device discovery, pairing, data exchange, and a connection stability wrapper with reconnection and retry backoff.

---

## Highlights / Goals
- Mocked BLE and Classic Bluetooth services that simulate scanning, connecting, reading/writing, and notifications/streams.
- Connection wrapper with a state machine supporting drops, retries, and auto-reconnect with backoff.
- GetX for state management (observables and dependencies).
- SharedPreferences to persist last connected device (demo flow auto-scans and attempts reconnect).
- MVVM-like folder structure and clear separation of concerns.
- Simple, minimal, professional UI with a scanning animation and status indicators.

---

## Folder structure
lib/
├── main.dart
├── constants.dart
├── core/
│   ├── bluetooth/
│   │   ├── ble_service.dart           // Mock BLE GATT behaviors
│   │   ├── classic_service.dart       // Mock Classic SPP behaviors
│   │   └── connection_wrapper.dart    // State machine + reconnect/backoff + logs
│   ├── models/
│   │   └── device_model.dart
│   └── utils/
│       └── retry_backoff.dart
├── viewmodels/
│   └── device_viewmodel.dart          // GetX controller handling scans, connect, data
├── views/
│   ├── scan_view.dart                 // Discover devices & start/stop scan
│   ├── device_detail_view.dart        // Live data, commands, logs for a device
│   ├── logs_view.dart                 // All connection logs
│   └── widgets/
│       └── connection_status.dart     // Small status indicator widget

---

## How it simulates Bluetooth
- BleService.startScan() and ClassicService.startScan() periodically generate fake DeviceModel objects and push them to streams.
- connect() in each service waits a short delay and randomly succeeds/fails to simulate real-world flaky connections.
- BLE "notifications" and Classic SPP streams are simulated via StreamControllers that periodically emit random payloads.
- read/write/send functions are simulated with delays and predictable responses (e.g., echo).
- ConnectionWrapper controls connection lifecycle and uses RetryBackoff for scheduling reconnections.

---

## Key flows
- Scan: Tap "Scan" on the main screen to start simulated discovery. A spinner indicates scanning.
- Connect: Tap Connect on a discovered device to attempt a mocked connection. The connection status updates and logs show events.
- Device screen: Watch simulated telemetry, send mock commands via BLE write or SPP send, and view logs.
- Auto-reconnect: When a connection drops (simulated), the wrapper will attempt reconnects with exponential backoff and jitter.
- Persistence: Last connected device string is stored in SharedPreferences (demo auto-scan tries to re-establish soon after launch).

---

## How to run
1. Ensure Flutter SDK is installed (Flutter 3.x+ recommended).
2. Add dependencies in `pubspec.yaml`:
   - get: ^4.x
   - shared_preferences: ^2.x
3. Run:
   - flutter pub get
   - flutter run

To produce an APK:
- flutter build apk --release
- The repo includes no special native plugins, so this is straightforward.

---

## Steps to upgrade to real BLE/Classic
1. Replace `core/bluetooth/ble_service.dart` with an implementation using `flutter_reactive_ble` or `flutter_blue` and wire the same API (startScan, connect, read, write, subscribeNotifications).
2. Replace `core/bluetooth/classic_service.dart` with a plugin capable of Classic SPP (Android-only) like `flutter_bluetooth_serial` or a platform channel implementation.
3. Keep `connection_wrapper.dart` and `device_viewmodel.dart` APIs intact so UI and logic remain unchanged.
4. Store structured device info in SharedPreferences (JSON) instead of `toString()`.
5. Add permissions:
   - AndroidManifest: BLUETOOTH, BLUETOOTH_ADMIN, ACCESS_FINE_LOCATION (as required), and Bluetooth connect/scan permissions for Android 12+.
   - iOS: Add NSBluetoothAlwaysUsageDescription / NSBluetoothPeripheralUsageDescription as needed.

---

## iOS build notes (if switching to real devices)
- Add necessary Info.plist entries for Bluetooth usage descriptions:
  - NSBluetoothAlwaysUsageDescription
  - NSBluetoothPeripheralUsageDescription
  - NSLocationWhenInUseUsageDescription (if scanning requires location)
- Enable Background Modes > Uses Bluetooth LE accessories (if you want background BLE).
- For Classic SPP, iOS does not support SPP over Bluetooth — you'll need to use BLE or MFi solutions.

---

## APK build setup
- Standard Flutter APK build:
  - flutter build apk --release
- For Play Store: prepare signing, store credentials in `key.properties` and configure `build.gradle` signingConfigs as usual.

---

## Demo video flow (suggested)
1. Launch app (shows home screen).
2. Tap "Scan" — animated spinner runs and devices appear.
3. Tap "Connect" on a device — status shows connecting with a progress indicator.
4. On successful connect, live data streams appear (updating) and logs show events.
5. Send a command (e.g., PING) and show echoed/ack response.
6. Simulate a connection drop by waiting until underlying mock disconnects — wrapper logs retries and auto-reconnect attempts, then reconnects.
7. Open Logs to show full history of events.

---

This project is a prototype to demonstrate correctness of flows and architecture. If you'd like, I can:
- Provide a full pubspec.yaml with specific version pins.
- Convert the last-connected persistence to structured JSON.
- Add unit tests for the connection wrapper's retry/backoff behavior.