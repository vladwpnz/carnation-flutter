<div align="center">

# 🚘 CarNation

### Flutter vehicle marketplace with Firebase-powered request management

A modern mobile application for discovering, saving, comparing, and requesting offers for selected vehicles.

![Flutter](https://img.shields.io/badge/Flutter-Mobile_App-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Application-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Authentication-FFCA28?logo=firebase&logoColor=black)
![Cloud Firestore](https://img.shields.io/badge/Cloud_Firestore-Request_Management-FF6F00?logo=firebase&logoColor=white)
![Material 3](https://img.shields.io/badge/Material_3-Dark_UI-6750A4?logo=materialdesign&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-64_passing-brightgreen)
![Android](https://img.shields.io/badge/Android-APK_Build-3DDC84?logo=android&logoColor=white)

</div>

---

## Overview

CarNation is a Flutter vehicle marketplace application that allows authenticated users to discover, filter, save, and compare vehicles, configure additional services, and submit persistent vehicle requests.

The application combines a modern dark automotive interface with Firebase Authentication, Cloud Firestore, real-time request tracking, secure user-owned data access, and a feature-oriented Flutter architecture.

The current application supports:

- email and password authentication;
- Firestore-backed user profiles;
- vehicle search, filtering, and sorting;
- detailed vehicle specification pages;
- Saved Cars;
- comparison of up to three vehicles;
- optional service selection;
- live price calculation;
- persistent Firestore requests;
- Firestore-generated request identifiers;
- real-time request history;
- request details and status timeline;
- cancellation of newly submitted requests;
- secure Firestore access rules;
- automated unit and widget testing.

---

## Current Status

CarNation is under active development.

The main authentication, vehicle discovery, saved-car, comparison, profile, request-management, and status-tracking flows are implemented and covered by automated tests.

Vehicle requests are persisted in Cloud Firestore, displayed in a real-time request history, and support status tracking and cancellation while still in the `Submitted` state.

Saved Cars and Compare selections currently remain available during the active application session and reset after the application restarts.

Cross-device Saved Cars, persistent Compare selections, custom avatar uploads, administrator tools, and notifications are planned for the next development phases.

---

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

- Create a persistent request for one selected vehicle
- Select optional vehicle services
- Prevent duplicate service selections
- Live services subtotal calculation
- Estimated total calculation
- Support for paid and free services
- Confirmation dialog
- Firestore-generated request ID
- Submission loading state
- Duplicate-submission prevention
- Request success screen
- Clear no-payment and no-reservation messaging

Vehicle requests are stored in Cloud Firestore and linked to the authenticated user.

### Request Management

- Real-time My Requests history
- Request cards with vehicle, total, date, and status
- Detailed request information
- Selected-service snapshots
- Vehicle snapshot stored with each request
- Real-time status updates
- Vertical request status timeline
- Submitted-request cancellation
- Recoverable loading and error states
- Persistent request history after application restart

### Request Statuses

CarNation supports the following request statuses:

1. `Submitted`
2. `Under review`
3. `Customer contacted`
4. `Offer prepared`
5. `Completed`
6. `Cancelled`

Status changes made in Cloud Firestore appear in the application in real time.

A user can cancel a request only while its status is `Submitted`. Cancelled requests remain in the request history and are not deleted.

---

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

Each request stores snapshots of its selected services so historical request information remains understandable even if the service catalogue changes later.

---

## Technology Stack

- Flutter
- Dart
- Material 3
- Firebase Authentication
- Cloud Firestore
- Firebase Storage dependency for planned media support
- Feature-oriented project structure
- Repository-based data access
- Real-time Firestore streams
- Transactional request cancellation
- Unit tests
- Widget tests

---

## Architecture

CarNation uses a feature-oriented project structure.

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
│   │   ├── application/
│   │   └── presentation/
│   ├── requests/
│   │   ├── application/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── saved/
│   │   ├── application/
│   │   └── presentation/
│   └── user_auth/
│       ├── data/
│       ├── firebase_auth_implementation/
│       └── presentation/
└── main.dart
```

The application separates:

- domain models;
- Firebase and data-access logic;
- application controllers;
- presentation pages;
- reusable widgets;
- navigation;
- theme configuration.

Firebase-specific types are kept inside the data layer. Domain models use regular Dart values and remain testable without connecting to Firebase.

---

## Firestore Data Model

Vehicle requests are stored in the top-level collection:

```text
requests/{requestId}
```

A request document contains:

```text
userId
contactEmail

car:
  id
  displayName
  modelYear
  imageAssetPath
  basePrice

services:
  - id
    title
    price

servicesSubtotal
estimatedTotal
status
createdAt
updatedAt
```

The vehicle and services are stored as snapshots. This keeps historical requests readable even when the local vehicle or service catalogues change later.

---

## Firestore Security

The repository includes Firestore Security Rules for:

```text
users/{userId}
requests/{requestId}
```

Authenticated users can:

- read their own profile;
- create and update their own permitted profile fields;
- create requests linked to their Firebase Authentication UID;
- read only their own requests;
- cancel only their own requests while the current status is `submitted`.

Authenticated users cannot:

- read another user's requests;
- create requests for another user;
- arbitrarily change request statuses;
- mark requests as completed;
- delete request documents;
- change vehicle, service, price, or ownership data during cancellation.

Later request statuses are intended to be managed through Firebase Console during development and through a trusted administrator application in a future phase.

---

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

---

## Firebase Setup

CarNation currently uses Firebase Authentication and Cloud Firestore.

To connect the application to an independent Firebase environment:

1. Create a Firebase project.
2. Register the Android application.
3. Enable Email/Password authentication.
4. Create a Cloud Firestore database.
5. Add the required Firebase platform configuration files.
6. Publish compatible Firestore Security Rules.
7. Run the application with an authenticated test account.

Private service-account credentials and administrator keys must never be committed to the repository.

The current Android and Firebase application identity is intentionally preserved for compatibility with the existing Firebase configuration.

---

## Testing

The project currently includes 64 automated tests covering:

- authentication interface behaviour;
- vehicle catalogue search;
- vehicle filtering and sorting;
- Saved Cars state;
- comparison limits;
- comparison duplicate prevention;
- Request Builder calculations;
- persistent request submission;
- submission loading behaviour;
- duplicate-submission prevention;
- Firestore request mapping;
- request-status mapping;
- invalid-status fallback;
- pending server timestamps;
- defensive numeric parsing;
- malformed service data;
- request history states;
- request card rendering;
- request details navigation;
- request status timeline;
- submitted-request cancellation;
- cancellation restrictions;
- recoverable repository errors;
- Profile request navigation;
- shared controller state;
- core application startup behaviour.

Current verification status:

- `flutter analyze` — passed
- `flutter test` — 64 tests passed
- Debug Android APK build — passed
- Real Firebase request submission — verified
- Firestore request persistence — verified
- Application restart persistence — verified
- Real-time status updates — verified
- Submitted-request cancellation — verified
- Firestore Security Rules — published and verified

---

## Verified Request Flow

The implemented request flow has been verified end to end:

```text
Vehicle Details
→ Request Builder
→ Firestore write
→ Request Submitted screen
→ My Requests
→ Request Details
→ Real-time status timeline
→ Submitted-request cancellation
```

The application does not show a success screen until the Firestore write completes successfully.

No payment is processed and submitting a request does not automatically reserve a vehicle.

---

## Roadmap

- Persist Saved Cars in Cloud Firestore
- Persist Compare selections
- Add custom profile avatar uploads through Firebase Storage
- Replace the temporary branding asset with a new CarNation logo
- Add Android and iOS application icons
- Build an administrator dashboard
- Add trusted administrator access controls
- Add request-status notifications
- Expand the vehicle catalogue
- Add production release configuration
- Add continuous integration workflows

---

## Author

**Vladyslav Spyrydonov**

GitHub: [vladwpnz](https://github.com/vladwpnz)

---

CarNation is an independently developed personal software project.
