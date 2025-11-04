# 🧘 Smart Yoga Mat (Mock Bluetooth Prototype)

A simple Flutter prototype simulating a smart yoga mat connection using **mock Bluetooth (BLE & Classic)**.  
Built as part of the **Arvyax Internship Assignment**.
[![Download APK](https://img.shields.io/badge/Download-APK-blue?style=for-the-badge&logo=android)](https://github.com/altaf1346/mattra/releases/download/app-debug.apk)


---

## 🎯 Objective
Demonstrate a basic Bluetooth connection workflow (mocked) with:
- Device discovery and pairing (simulated)  
- Data exchange via mock BLE GATT and Classic SPP  
- Auto reconnect, retries, and timeout handling (connection wrapper)  
- Clean and simple UI to show connection status and live data  

---

## ⚙️ Tech Stack
- **Framework:** Flutter  
- **State Management:** GetX  
- **Local Storage:** SharedPreferences (to save last paired device)  
- **Architecture:** MVVM (ViewModel + Service + View)  
- **Mock Data:** Simulated BLE & Classic Bluetooth services  

---

## 📂 Folder Structure
```
lib/
├── core/
│   ├── bluetooth/
│   │   ├── ble_service.dart
│   │   ├── classic_service.dart
│   │   └── connection_wrapper.dart
│   ├── models/device_model.dart
│   └── utils/retry_backoff.dart
├── viewmodels/device_viewmodel.dart
├── views/
│   ├── scan_view.dart
│   ├── device_detail_view.dart
│   └── logs_view.dart
└── widgets/connection_status.dart
```

---

## 🚀 Getting Started
1. Clone the repo  
   ```bash
   git clone https://github.com/altaf1346/mattra.git
   cd mattra
   flutter pub get
   ```
2. Run the app  
   ```bash
   flutter run
   ```

---

## 🍏 iOS Build Notes
If testing on iOS:
- Enable **Bluetooth Background Mode** in Xcode (`Runner > Signing & Capabilities > Background Modes`).
- Enable: ✅ Uses Bluetooth LE Accessories  
- No Apple Developer Account required for mock build.

---

## 🎥 Demo Video Script (3 mins)
**Intro (30s):**  
“Hi, this is my Flutter prototype for connecting a smart yoga mat using mock Bluetooth simulation.”

**Part 1 (1 min):**  
Show **Scan Screen** discovering mock devices.  
Explain GetX logic managing state and simulating connection attempts.

**Part 2 (1 min):**  
Show **Device Detail Screen** — mock data streaming (heart rate, posture, or mat pressure).  
Explain retry/reconnect logic handled in `connection_wrapper.dart`.

**Part 3 (30s):**  
Show **Logs View** with connection events and last paired device restored from SharedPreferences.  
End with “This demonstrates a reliable connection layer and smooth UI.”

---

## 🔮 Future Scope
- Replace mock Bluetooth with real ESP32 GATT and SPP services.  
- Add real sensor data visualization (pressure, pose tracking).  
- Extend with Firebase sync for session logs.
