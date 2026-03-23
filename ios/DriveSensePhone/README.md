# DriveSensePhone

DriveSensePhone is the native iPhone app for DriveSense, a mileage and trip insights product for business drivers.

## Current App Scope

The current build includes:

- SwiftUI app shell
- Automatic trip detection scaffolding with `Core Location` and `Core Motion`
- Local trip storage
- Trip summaries with mileage, time, speed, stopped time, and driving-behavior indicators
- Demo scenarios for simulator presentations
- Seeded sample history for a more polished first-launch experience

## Intended Use

The app is positioned to help users:

- track business mileage
- review trip history before tax filing
- understand driving habits and trip quality
- keep better records than manual mileage logs

## Open in Xcode

Open:

```text
ios/DriveSensePhone/DriveSensePhone.xcodeproj
```

Then choose an iPhone simulator or device and run the app.

## Demo Notes

- In Simulator, use the built-in demo scenarios to show live trip playback.
- On a real iPhone, `Always Location` and `Motion & Fitness` improve automatic trip capture.
- The app is optimized to present well in meetings with preloaded trip history and realistic sample flows.

## Remaining Product Work

Before production release, the main next steps would be:

- onboarding and permission education
- tighter trip-detection accuracy
- route map presentation
- reporting exports and totals views
- branding, app icon, and release packaging
