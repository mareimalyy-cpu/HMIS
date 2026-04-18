# HMIS — Hospital Management Information System

A Flutter mobile application for managing hospital operations including patients, doctors, and appointments. Supports Arabic and English with full dark/light mode.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Roles & Access](#roles--access)
- [Screens & Navigation](#screens--navigation)
- [Getting Started](#getting-started)
- [Firebase Setup](#firebase-setup)
- [Localization](#localization)
- [State Management](#state-management)
- [Environment](#environment)

---

## Features

### Patient
- Browse doctors by medical specialty
- View doctor details (bio, schedule, contact)
- Book appointments with symptom description
- View appointment history
- Profile management

### Doctor
- View today's appointments dashboard
- Access full patient records
- Profile management
- Push notification support

### Admin
- Dashboard with stats (doctors, patients, appointments count)
- Weekly appointments chart
- Manage doctors (edit name, phone, specialty, hospital)
- Manage patients (view profiles, appointment history)
- Delete appointments

### General
- Arabic / English localization
- Dark & light mode (system, manual)
- Font size control
- Push notifications (Firebase + local)
- Google Sign-In
- Onboarding screens (first launch only)
- Role-based auto-routing (no re-login on app restart)

---

## Tech Stack

| Category | Package | Version |
|---|---|---|
| Framework | Flutter + Dart | SDK ^3.10.1 |
| Auth & DB | Firebase Auth, Firestore | 6.1.2 / 6.1.0 |
| Push Notifications | firebase_messaging + flutter_local_notifications | 16.0.4 / 21.0.0 |
| State Management | flutter_riverpod + riverpod_annotation | 3.0.3 |
| Navigation | go_router | 17.0.0 |
| Localization | easy_localization | 3.0.8 |
| Local Storage | hive_flutter | 1.1.0 |
| HTTP | dio | 5.9.0 |
| Auth (Google) | google_sign_in | 7.2.0 |
| Images | image_picker | 1.2.1 |
| Responsive | responsive_framework | 1.5.1 |
| SVG | flutter_svg | 2.2.3 |
| Skeleton loading | skeletonizer | 2.1.1 |

---

## Project Structure

```
lib/
├── core/
│   ├── enum/               # App-wide enums & constants
│   ├── extension/          # Dart extensions (theme, font, language)
│   ├── local_services/     # Hive local storage wrapper
│   ├── notifications/      # Local notification service
│   ├── router/             # GoRouter setup (mobile / web / iPad)
│   ├── services/           # Network service (Dio)
│   ├── themes/             # AppTheme, AppColors, styles
│   └── widgets/            # Shared widgets (AppButton, SearchField, DoctorCard…)
│
├── features/
│   ├── admin_home/         # Admin dashboard, patients & doctors management
│   ├── auth/               # Login, register, role selection, Google Sign-In
│   ├── booking/            # Book appointment + success screen
│   ├── clinics/            # Doctor listing by specialty + doctor details
│   ├── doctor_home/        # Doctor shell, home, records
│   ├── doctor_profile/     # Doctor profile page
│   ├── doctor_records/     # Patient records for doctors
│   ├── onboarding/         # Onboarding slides (shown once)
│   ├── patient_appointments/ # Patient appointment list
│   ├── patient_home/       # Patient shell, home, specialties
│   ├── patient_profile/    # Patient profile page
│   ├── search/             # Global doctor search
│   └── settings/           # Theme, language, font size, notifications
│
├── generated/              # locale_keys.g.dart (auto-generated)
├── firebase_options.dart
└── main.dart
```

---

## Roles & Access

| Role | Entry Point | Registration |
|---|---|---|
| **Patient** | `/patient-home` | In-app registration |
| **Doctor** | `/doctor-home` | In-app registration |
| **Admin** | `/admin-home` | Firestore only (`role: "admin"`) |

> Admin accounts must be created directly in Firestore — there is no admin registration screen.

---

## Screens & Navigation

### Route Map

```
/onboarding               ← First launch only
/role-selection           ← Choose patient or doctor
/login                    ← Email/password + Google Sign-In
/patient-register
/doctor-register
/complete-profile         ← After Google Sign-In if profile is incomplete

/patient-home             ← Patient shell (Home, Search, Appointments, Account)
/clinics                  ← Doctors list by specialty
/doctor-details           ← Doctor profile + book button
/booking                  ← Book appointment form
/booking-success

/doctor-home              ← Doctor shell (Home, Records, Account)

/admin-home               ← Admin shell (Dashboard, Patients, Doctors)
/admin-patient-detail     ← Patient detail with appointment history

/settings                 ← Theme, language, font size, notifications
```

### Auto-routing on launch

The app reads the saved `userRole` from local storage and routes directly to the correct home without re-login:

```
App launch
  ↓
First time?       → /onboarding
Logged in?
  patient         → /patient-home
  doctor          → /doctor-home
  admin           → /admin-home
Not logged in     → /role-selection
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.10.1`
- Dart SDK `^3.10.1`
- Android Studio / Xcode
- Firebase project configured (see [Firebase Setup](#firebase-setup))

### Run

```bash
# Install dependencies
flutter pub get

# Run code generation (Riverpod providers + assets)
dart run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Firebase Setup

The app uses the following Firebase services:

| Service | Usage |
|---|---|
| Firebase Auth | Email/password + Google Sign-In |
| Cloud Firestore | Users, appointments, specialties |
| Firebase Messaging | Push notifications |

### Firestore Collections

| Collection | Description |
|---|---|
| `users` | All users — role field: `patient`, `doctor`, `admin` |
| `appointments` | All appointments — linked by `patientId` and `doctorId` |
| `specialties` | Medical specialties list |

### Add Firebase to the project

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android & iOS apps
3. Download `google-services.json` → place in `android/app/`
4. Download `GoogleService-Info.plist` → place in `ios/Runner/`
5. Run:
```bash
flutterfire configure
```

---

## Localization

Supports **Arabic** and **English**. Translation files are in:

```
assets/translations/
├── ar.json
└── en.json
```

All keys are generated in `lib/generated/locale_keys.g.dart` and used as:

```dart
LocaleKeys.book_now.tr()
```

To add a new key:
1. Add to both `ar.json` and `en.json`
2. Run:
```bash
dart run easy_localization:generate -S assets/translations -O lib/generated -o locale_keys.g.dart -f keys
```

---

## State Management

Uses **Riverpod** with code generation:

```dart
// Define a provider
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Future<AuthStates> build() async { ... }
}

// Watch in widget
final authState = ref.watch(authProvider);
```

After modifying any `@riverpod` annotated file, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Environment

| Platform | Min SDK | Target SDK | JVM |
|---|---|---|---|
| Android | flutter default | flutter default | Java 17 |
| iOS | flutter default | — | — |

Core library desugaring is enabled for `flutter_local_notifications` support on older Android versions.

---

## Assets

```
assets/
├── images/
│   ├── png/
│   │   ├── app-logo.png
│   │   └── doc.png
│   └── svg/
│       ├── on1.svg          ← Onboarding slide 1
│       ├── on2.svg          ← Onboarding slide 2
│       ├── on3.svg          ← Onboarding slide 3
│       └── no-search.svg    ← Empty search state
└── translations/
    ├── ar.json
    └── en.json
```
