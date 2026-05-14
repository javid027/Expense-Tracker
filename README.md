# Finora Expense Tracker

Finora is an offline-first Flutter finance tracker redesigned from a basic expense app into a cleaner, premium-style personal money manager. It runs fully on local storage, has no authentication or backend dependency, and focuses on fast day-to-day expense tracking with modern UI, analytics, and budget visibility.

## Overview

This project is built as a local-first personal finance app with:

- premium dashboard styling
- responsive layouts for phones, tablets, and larger screens
- local transaction and budget persistence
- analytics and category breakdowns
- light and dark theme support
- clean feature-first architecture

The app currently ships with:

- `Dashboard`
- `Transactions`
- `Analytics`
- `Budgets`
- `Settings`

## Current Feature Set

### Dashboard

- monthly balance overview
- income and expense summary cards
- 7-day spending chart
- recent activity preview
- budget progress strip
- monthly spending insight summary

### Transactions

- add transaction
- edit transaction
- delete transaction
- category selection
- notes support
- recurring frequency field
- search by title and notes
- filter by category
- filter by type
- filter favorites only
- sort by latest, oldest, highest, and lowest
- swipe to favorite
- swipe to delete

### Budgets

- category-based monthly budgets
- progress indicators
- warning-style progress visualization when usage gets high
- add budget
- delete budget

### Analytics

- monthly snapshot
- category spending breakdown
- pie chart with percentage distribution
- category comparison progress rows
- local insight message generation

### Settings

- theme mode switcher
- privacy placeholders for encryption and biometric lock
- local data action cards for export, backup, and reminders

## Offline-First Scope

This app is intentionally local-first.

- No backend
- No login
- No API integration
- No cloud sync

All primary app data is stored locally using Hive boxes.

## Tech Stack

- `Flutter`
- `Material 3`
- `flutter_riverpod`
- `go_router`
- `Hive`
- `fl_chart`
- `flutter_animate`
- `flutter_screenutil`
- `intl`
- `shimmer`
- `uuid`

Included and ready for deeper integration:

- `local_auth`
- `flutter_local_notifications`
- `image_picker`
- `pdf`
- `csv`
- `share_plus`
- `freezed`
- `json_serializable`

## Architecture

The project uses a lightweight clean architecture direction with feature-first organization.

```text
lib/
  app/
    app.dart
    router.dart
  core/
    storage/
    theme/
    utils/
  features/
    analytics/
      presentation/
    budgets/
      data/
      domain/
      presentation/
    dashboard/
      presentation/
    settings/
      presentation/
    transactions/
      data/
      domain/
      presentation/
  shared/
    widgets/
  main.dart
```

### Layering

- `domain`: core models and business-level types
- `data`: repositories and persistence access
- `presentation`: UI, controllers, filters, charts, forms
- `shared`: reusable widgets and layout building blocks
- `core`: theme, storage bootstrapping, formatting, utilities

## Navigation

Routing is handled through `GoRouter` with a shared shell layout.

Routes:

- `/` -> Dashboard
- `/transactions` -> Transactions
- `/analytics` -> Analytics
- `/budgets` -> Budgets
- `/settings` -> Settings

## State Management

State is handled with Riverpod.

Main providers include:

- `routerProvider`
- `themeModeProvider`
- `localDatabaseProvider`
- `transactionsControllerProvider`
- `budgetsControllerProvider`

## Local Storage

Hive is used as the local database layer.

Current boxes:

- `transactions_v2`
- `budgets_v2`
- `settings_v2`

## UI Direction

The UI system was rebuilt to be calmer and more usable with:

- softer premium green and neutral palette
- flatter cards with lighter elevation
- cleaner charts
- non-sticky headers
- better spacing and hierarchy
- consistent section headers
- bottom-sheet based filtering

## Design Notes

The current visual direction is intentionally:

- cleaner than neon fintech clones
- less glass-heavy
- more readable for daily use
- focused on practical information density

## Testing

Current tests cover:

- transaction JSON round-trip
- analytics totals and insight generation
- transaction filtering
- transaction sorting
- transaction search matching

Run tests with:

```bash
flutter test
```

Run static analysis with:

```bash
flutter analyze
```

## Build Status

Verified in this workspace:

- `flutter analyze` passes
- `flutter test` passes
- `flutter build apk --debug` passes

Debug APK output:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Getting Started

### Prerequisites

- Flutter stable
- Dart SDK compatible with the Flutter version
- Android Studio or VS Code
- Android SDK for Android builds

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

### Build debug APK

```bash
flutter build apk --debug
```

## Windows Note

If you are developing on Windows and package resolution/building complains about symlink support, enable Developer Mode:

```text
start ms-settings:developers
```

Then turn on Developer Mode in Windows settings.

## Android Note

`flutter_local_notifications` requires core library desugaring. This project already includes the required Gradle configuration in:

- `android/app/build.gradle`

## Recommended Next Improvements

The following packages are already included or partially prepared, but the full product flows can be expanded further:

- receipt capture with `image_picker`
- PDF export using `pdf`
- CSV export using `csv`
- share/export flows using `share_plus`
- biometric app lock with `local_auth`
- local reminders with `flutter_local_notifications`
- encrypted local storage key management
- backup and restore file flow
- Freezed-based immutable models and generated serializers

## Accessibility and Performance Direction

The project is structured to support:

- reduced rebuilds through Riverpod separation
- reusable shared widgets
- responsive shell navigation
- stronger visual contrast than the earlier version
- more readable charts and spacing

## Version

- App version: `2.0.0+2`

## Project Goal

The purpose of this project is to provide a polished offline-first finance tracker foundation that can keep growing into a more advanced personal finance product without requiring a backend from day one.
