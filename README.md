# DriveSense

DriveSense is a mobile mileage and trip insights app designed for self-employed professionals, contractors, consultants, and small business owners. It helps users automatically track business mileage, organize trip history for income tax reporting, and review driving habits such as smoothness, stop patterns, and trip quality.

## Product Overview

DriveSense is built around three simple goals:

- Capture business trips with as little manual work as possible
- Keep mileage records easier to review at tax time
- Give users a clearer picture of how they drive from trip to trip

The iPhone app focuses on:

- Automatic trip detection using iPhone location and motion signals
- Mileage tracking and local trip history
- Trip summaries with distance, duration, speed, and stopped time
- Driving behavior review such as harsh braking and rapid acceleration estimates
- Simulator-friendly demo controls for client presentations

## Key Benefits

- Better mileage visibility for business income tax preparation
- Cleaner records for reimbursable or deductible driving
- Fast review of recent trips, totals, and driving patterns
- A more polished experience than manually logging miles in a spreadsheet

## iPhone App

Open the iPhone project in Xcode:

```text
ios/DriveSensePhone/DriveSensePhone.xcodeproj
```

To run it:

1. Open the Xcode project.
2. Select the `DriveSensePhone` target.
3. Set your Apple development team in `Signing & Capabilities`.
4. Change the bundle identifier to something unique.
5. Choose an iPhone simulator or your physical iPhone.
6. Press Run.

Notes:

- The app demos well in the iPhone Simulator.
- The simulator includes seeded history and demo-drive scenarios for presentations.
- Real automatic trip detection works best on a physical iPhone.
- `Motion & Fitness` and `Always Location` improve automatic trip capture.

## Demo Experience

The simulator build is set up to present well to clients:

- Preloaded sample trip history
- Multiple demo scenarios such as city, highway, and rushed driving
- Live speed, distance, and trip-progress visuals during demo playback
- Trip detail screens that show mileage totals and driving behavior summaries

## GitHub Pages Demo

This repository includes a browser-based product demo in:

```text
docs/
```

GitHub Pages can display the web demo, screenshots, and documentation, but it cannot run the native iPhone app itself.

To publish the web demo with GitHub Pages:

1. Push the repository to GitHub.
2. Open the repository on GitHub.
3. Go to `Settings > Pages`.
4. Under `Build and deployment`, choose `Deploy from a branch`.
5. Select your main branch.
6. Select the `/docs` folder.
7. Save.

After publishing, visitors will be able to click your GitHub Pages link and explore the product interface in their browser.

## Repository Contents

This repository includes:

- The native iPhone app under `ios/DriveSensePhone/`
- A browser demo for GitHub Pages under `docs/`
- An earlier C++ prototype used to explore trip analysis and scoring logic

## Prototype

The C++ prototype remains in the repository as a supporting engineering artifact. It includes CSV parsing, trip metric calculation, and driving-event detection logic.

Build:

```bash
cmake -S . -B build
cmake --build build
```

Run:

```bash
./build/drivesense
```

## Best Presentation Setup

For a client-facing presentation, the strongest setup is:

- The iPhone Simulator for a guided live demo
- GitHub Pages for a clickable browser preview
- A few screenshots or a short demo video in the repository
# Drive-Sense
# Drive-Sense
# Drive-Sense
# Drive-Sense
