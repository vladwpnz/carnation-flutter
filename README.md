# CarNation

CarNation is a modern Flutter vehicle marketplace application for discovering, saving, comparing, and requesting offers for selected vehicles.

The application combines a dark automotive interface with Firebase Authentication, Firestore-backed user profiles, catalogue filtering, detailed vehicle pages, comparison tools, and a configurable request-building flow.

## Current Status

CarNation is under active development.

The main authentication, vehicle discovery, saved-car, comparison, profile, and Request Builder interfaces are implemented and covered by automated tests.

Request persistence, request tracking, cross-device saved data, custom avatar uploads, administrator tools, and notifications are planned for the next development phases.

## Features

### Authentication and Profiles

- Email and password registration
- Email and password login
- Firebase Authentication session handling
- Authentication-aware application routing
- Firestore-backed user profiles
- Input validation
- Loading and error states
- Safe logout flow

### Vehicle Catalogue

- Modern dark automotive interface
- Local vehicle catalogue
- Search by brand, model, and description
- Brand filtering
- Advanced vehicle filters
- Multiple sorting options
- Vehicle result counter
- Responsive vehicle cards
- Detailed vehicle specification pages

### Saved Vehicles

- Save and remove vehicles
- Duplicate prevention
- Dedicated Saved Cars page
- Shared state during the current application session

Saved vehicles are currently stored in memory and reset after the application restarts.

### Vehicle Comparison

- Compare up to three vehicles
- Duplicate prevention
- Side-by-side specification comparison
- Remove vehicles from comparison
- Responsive horizontal comparison layout

Comparison selections are currently stored in memory and reset after the application restarts.

### Request Builder

- Create a request for one selected vehicle
- Select optional vehicle services
- Prevent duplicate service selections
- Live services subtotal calculation
- Estimated total calculation
- Support for paid and free services
- Confirmation dialog
- Request summary screen
- Clear no-payment and no-reservation messaging

Request submission is currently implemented as a frontend demonstration flow. It does not yet create a persistent Firestore request or notify an administrator.

## Optional Services

The current Request Builder supports:

- Full pre-delivery inspection and service
- Interior and exterior detailing
- Extended warranty
- Winter wheel package
- Vehicle delivery
- Registration assistance
- Trade-in consultation
- Test-drive request

## Technology Stack

- Flutter
- Dart
- Material 3
- Firebase Authentication
- Cloud Firestore
- Firebase Storage dependency for planned media support
- Feature-oriented project structure
- Repository-based profile data access
- Lightweight application controllers
- Unit and widget testing

## Project Structure

```text
lib/
├── core/
│   ├── navigation/
│   └── theme/
├── features/
│   ├── app/
│   ├── cars/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── compare/
│   ├── requests/
│   ├── saved/
│   └── user_auth/
└── main.dart
```

The project uses a feature-oriented structure that separates domain models, data access, application controllers, and presentation components.

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Android SDK
- Java 17
- Android emulator or physical Android device
- Firebase project configured for the application

### Installation

Clone the repository:

```bash
git clone https://github.com/vladwpnz/carnation-flutter.git
cd carnation-flutter
```

Install dependencies:

```bash
flutter pub get
```

Run static analysis:

```bash
flutter analyze
```

Run automated tests:

```bash
flutter test
```

Launch the application:

```bash
flutter run
```

Build a debug Android APK:

```bash
flutter build apk --debug
```

## Firebase Setup

CarNation currently uses Firebase Authentication and Cloud Firestore.

To connect the application to an independent Firebase environment:

1. Create a Firebase project.
2. Register the Android application.
3. Enable Email/Password authentication.
4. Create a Cloud Firestore database.
5. Add the required Firebase platform configuration files.
6. Configure Firestore Security Rules before working with real user data.

Private service-account credentials and administrator keys must never be committed to the repository.

## Testing

The project currently includes 39 automated tests covering:

- Authentication interface behaviour
- Vehicle catalogue search, filtering, and sorting
- Saved vehicle state
- Comparison limits and duplicate prevention
- Request Builder calculations
- Navigation between marketplace screens
- Shared controller state
- Core application startup behaviour

Current verification status:

- `flutter analyze` — passed
- `flutter test` — 39 tests passed
- Debug Android APK build — passed

## Roadmap

- Persist vehicle requests in Cloud Firestore
- Generate request IDs
- Add request history
- Add request status tracking and a progress timeline
- Allow cancellation of newly submitted requests
- Persist Saved Cars in Firestore
- Persist Compare selections
- Add custom profile avatar uploads through Firebase Storage
- Replace the temporary branding asset with a new CarNation logo
- Add Android and iOS application icons
- Build an administrator dashboard
- Add request-status notifications
- Expand the vehicle catalogue
- Add production-ready Firebase Security Rules

## Author

**Vladyslav Spyrydonov**

GitHub: [vladwpnz](https://github.com/vladwpnz)

---

CarNation is an independently developed personal software project.
