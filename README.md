# Booker

A two-sided appointment booking platform built with Flutter and Firebase. Service providers set up their profiles, services, schedules, and pricing; clients browse, book, and pay.

## Features

- **Appointment scheduling** with Syncfusion calendar integration and blocked time periods
- **Stripe payments** for booking and subscription management
- **Firebase backend** — Auth (email + Google), Firestore, Storage, Cloud Functions
- **Client management** — providers can track their clients and appointment history
- **Service configuration** — customizable services with pricing, duration, and availability
- **Multi-language support** via Flutter l10n

## Architecture

```
lib/
├── models/          # Data models (user, appointment, service, subscription, ...)
├── views/           # 26 screens (auth, calendar, booking, profile, payments, ...)
├── widgets/         # Reusable UI components
├── helper/          # Utilities and shared logic
└── l10n/            # Localization

functions/           # Firebase Cloud Functions (TypeScript)
```

## Setup

### Prerequisites
- Flutter 3.2+
- Firebase project with Auth, Firestore, and Storage enabled
- Stripe account

### Run

```bash
flutter pub get
flutter run
```

## Tech Stack

- **Frontend:** Flutter, Syncfusion Calendar, Provider
- **Backend:** Firebase (Auth, Firestore, Storage, Cloud Functions)
- **Payments:** Stripe
