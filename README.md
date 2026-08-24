# GreaseTrail

A vehicle maintenance tracker — log service history, set km/month intervals per
category, and see what needs attention at a glance. Ported from the original
React Native/Expo app to Flutter.

## Structure

- `lib/theme.dart` — colors, typography, spacing
- `lib/models.dart` — Vehicle/Category/LogEntry data model, templates, due-status logic
- `lib/storage.dart` — on-device persistence (`shared_preferences`)
- `lib/widgets/` — shared UI components (cards, fields, tab bar, top bar)
- `lib/screens/` — Garage, Log, Setup, and the vehicle/category detail flows

## Running in Xcode

```
flutter pub get
open ios/Runner.xcworkspace
```

Select the `Runner` scheme and a simulator or device, then press Run. You can
also run from the CLI with `flutter run`.
