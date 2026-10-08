# Smart BloodLink 🩸

**An emergency blood coordination platform** connecting patients, verified donors, hospitals, ambulance operators, and administrators through a single Flutter mobile application.

> Built as a PBL III project (MVVM · Firebase · Flutter · Material 3)

---

## Features at a Glance

| Module | Highlights |
|--------|-----------|
| **Patient** | Create blood requests, real-time donor/hospital matching, live ambulance GPS tracking |
| **Donor** | Accept/decline requests, eligibility checker, gamification badges & leaderboard |
| **Hospital** | Inventory management, RFID bag scanning, IoT cold-chain temperature monitoring |
| **Ambulance** | Trip dashboard, turn-by-turn navigation canvas, OTP-based delivery confirmation |
| **Admin** | User verification, global stock view, audit logs, analytics reports, system settings |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.x · Material 3 · Dark/Light mode |
| State | Provider (MVVM) |
| Backend | Firebase Auth · Cloud Firestore · Cloud Functions · Firebase Storage · FCM |
| IoT | ESP32 sensor telemetry → Cloud Functions → Firestore |
| RFID | Simulated scanner overlay → bag lifecycle state machine |
| Maps | Custom vector canvas (demo) / Google Maps Flutter (production) |
| Charts | fl_chart |

---

## Project Structure

```
lib/
├── main.dart                    # App entry point, MultiProvider root
├── models/                      # Pure data classes (9 models)
├── services/                    # Business logic singletons + MockDataService
├── repositories/                # Data access layer (7 repos)
├── providers/                   # MVVM ViewModels (8 ChangeNotifiers)
├── screens/
│   ├── auth/                    # Splash, Onboarding, Login, Register, OTP
│   ├── patient/                 # 8 patient screens
│   ├── donor/                   # 8 donor screens
│   ├── hospital/                # 8 hospital screens
│   ├── ambulance/               # 6 ambulance screens
│   ├── admin/                   # 7 admin screens
│   └── common/                  # Profile, Edit Profile
├── widgets/                     # 12 reusable widgets
└── utils/                       # Themes, colors, constants, helpers

functions/
├── index.js                     # Cloud Function triggers
├── matchingEngine.js            # Parallel donor + hospital matching
└── iotWatcher.js                # ESP32 telemetry + breach detection
```

---

## Getting Started

### Prerequisites

1. **Flutter SDK** — Install from https://docs.flutter.dev/get-started/install/windows
   ```powershell
   winget install Google.Flutter
   # then restart your terminal
   flutter doctor
   ```

2. **Android Studio** or Android SDK (for device/emulator)

3. *(Optional for full features)* **Firebase project** + `google-services.json`

### Run in Demo Mode (no Firebase needed)

The app ships with a full `MockDataService` — no Firebase account or `google-services.json` is required to compile and run.

```powershell
cd d:\smartBloodLink
flutter pub get
flutter run
```

### 1-Tap Demo Login

On the Login screen, tap any of the coloured role shortcut buttons:

| Button | Role | Credentials used |
|--------|------|-----------------|
| 🔴 Patient | Patient | patient@demo.com |
| 🟢 Donor | Donor | donor@demo.com |
| 🔵 Hospital | Hospital Staff | hospital@demo.com |
| 🟡 Ambulance | Ambulance Op. | ambulance@demo.com |
| ⚫ Admin | Administrator | admin@demo.com |

---

## Firebase Setup (Production)

1. Create a Firebase project at https://console.firebase.google.com
2. Add an Android app with package `com.smartbloodlink.app`
3. Download `google-services.json` → place in `android/app/`
4. Enable **Authentication** (Email/Password)
5. Create **Firestore** database (start in test mode, then apply `firestore.rules`)
6. Deploy Cloud Functions:
   ```bash
   cd functions
   npm install
   firebase deploy --only functions
   ```
7. In `lib/main.dart`, add before `runApp`:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

---

## Architecture

```
Screen  →  Provider (ChangeNotifier)  →  Repository  →  Service / MockDataService
                                                              ↓
                                                        Firebase / ESP32
```

All services are singletons. `MockDataService` holds mutable in-memory lists that every repository reads/writes — no network calls needed for the demo.

---

## IoT Cold-Chain Simulation

`IotMonitoringService` starts a `Timer.periodic(4 s)` that generates synthetic ESP32 temperature readings. When temperature exceeds the threshold (default **8 °C**), an alert is added to `NotificationService` and the sensor reading is flagged `isBreach: true`.

---

## RFID Bag Lifecycle

```
manufactured → quarantine → available → reserved → dispatched → delivered → expired
```

Each transition is validated by `RfidService.updateBagStatus()` with an audit log entry.

---

## License

Academic project — PBL III, 2024. Not for commercial distribution.
