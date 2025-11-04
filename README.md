```markdown
# Mattra — Arvyax Smart Mat (Mock) — Flutter Prototype

Welcome — this repository contains a Flutter internship prototype that simulates connecting to a smart yoga mat (ESP32) using mocked Bluetooth (BLE + Classic). The app demonstrates scanning, connecting, data streaming (mock GATT notifications and SPP), a connection-stability wrapper with retry/backoff, and a small modern UI built with GetX.

Quick links
- Repository: https://github.com/altaf1346/mattra
- APK (release asset): https://github.com/altaf1346/mattra/releases/latest  ← click "Assets" to download the APK
- Demo video (2:30): Add to Releases or upload to YouTube and paste the link here (see instructions below)

Download APK
- The easiest way to get the APK is via the GitHub Release for this repo. Go to:
  https://github.com/altaf1346/mattra/releases/latest
  and expand "Assets" to download `mattra.apk`.
- If the APK is not yet attached to a release, follow the "Attach APK & Video" steps below.

Watch demo video
- A short demonstration video (approx 2:30) was recorded to show the flows (scan → connect → live data → sending commands → reconnection). If you uploaded it to the repository releases or a public video host, paste the direct link here. Example YouTube embed:
  - https://www.youtube.com/watch?v=YOUR_VIDEO_ID

What this app shows (short)
- Mock BLE and Classic Bluetooth scanning (simulated devices generated periodically).
- Connect/disconnect flow with random success/failure to simulate real-world instability.
- Mock data streams:
  - BLE: simulated GATT notifications (utf8 payloads).
  - Classic: simulated SPP stream with echo responses.
- ConnectionWrapper: state machine (disconnected, connecting, connected, reconnecting) + exponential backoff with jitter for automatic reconnect attempts.
- GetX state management and SharedPreferences for persisting the last connected device (demo behavior).
- Simple UI: Scan screen, Device details screen (live data + command entry), Logs screen, connection status widget.

How to download and run the APK on Android
1. On your Android device, enable "Install unknown apps" for the browser or file manager you'll use to open the APK.
2. Download the APK from the Release assets:
   - https://github.com/altaf1346/mattra/releases/latest → click Assets → download `mattra.apk`
3. Open the downloaded APK on your Android device and install it.
4. Launch the app. It will request Bluetooth/location permissions (demo flow). Tap "Scan" to see mock devices appear and try connecting.

Attach the APK & Demo Video to GitHub Releases (recommended)
1. In GitHub, open this repository: https://github.com/altaf1346/mattra
2. Click "Releases" → "Draft a new release".
3. Enter a tag (e.g., `v1.0`) and a title (e.g., `v1.0 — APK + Demo`).
4. In "Attach binaries by dropping them here or selecting them", upload:
   - `mattra.apk` (the release APK)
   - `mattra-demo.mp4` (the recorded 2:30 video)
5. Optionally add release notes / summary of what's in the demo.
6. Publish the release.
7. After publishing, you can link directly to the APK via:
   - https://github.com/altaf1346/mattra/releases/download/v1.0/mattra.apk
   and to the video via:
   - https://github.com/altaf1346/mattra/releases/download/v1.0/mattra-demo.mp4

Suggested README sections you can expand later
- Setup & run locally (flutter pub get, flutter run)
- pubspec.yaml deps list (GetX, shared_preferences, permission_handler)
- File map & short description of each file (for quick code tour during interviews)
- How to replace mocks with real Bluetooth plugins (flutter_reactive_ble, flutter_bluetooth_serial)
- iOS build notes (Info.plist Bluetooth keys & background mode)

Demo script (what to show in a 2–3 minute demo)
1. Open the app and explain this is a mock prototype that simulates Bluetooth devices.
2. Tap "Scan" — point out scanning spinner and devices populating.
3. Tap "Connect" on one device — show status transition to Connected and live data updating.
4. Type a command (e.g., PING) and press Send — show echo/ack in logs or stream area.
5. Mention that the app will automatically attempt reconnects when a drop occurs (simulated with random failures) and show the Logs view to see reconnect attempts.

Developer notes (if you want to edit or repackage)
- To build an APK locally:
  - flutter build apk --release
  - Your APK will be in `build/app/outputs/flutter-apk/app-release.apk`
- To add release signing, configure `key.properties` and `android/key.properties` per Flutter docs.
- To replace mock BLE/Classic with real implementations, implement the same service interface and inject them in main.dart.

If you want, I added quick instructions above for attaching assets to a Release. I also prepared the README so the interviewer or evaluator can immediately download the APK and watch the demo — if you already attached the APK and video to the repo releases, the "Download APK" and "Demo video" links will work. If you haven't attached them yet, follow the "Attach APK & Demo Video to GitHub Releases" steps and then paste the final direct URLs here and I'll update the README to reference the exact asset URLs.

```
