# SONICHE

An iPhone-first AI personal stylist app, built natively with Swift and SwiftUI.

## Requirements

- macOS 15.6 or newer with Xcode 26 (Xcode 16 also works)
- iOS 17 or newer on device or simulator
- iPhone only

## Run the app

1. Clone the repository.
2. Open `Soniche.xcodeproj` in Xcode.
3. Choose an iPhone simulator in the toolbar and press Run.

To run on a physical iPhone, select the Soniche target, open Signing & Capabilities,
and choose your Apple ID team once. Xcode stores that choice locally.

## Run the tests

Press Cmd+U in Xcode, or from Terminal:

```sh
./scripts/test.sh
```

GitHub Actions runs the same script on every push.

## Project layout

```
Soniche.xcodeproj/        Xcode project (app target and shared scheme)
Soniche/                  App shell: entry point, assets, app configuration
Packages/SonicheKit/      Swift package holding the app's features, models, and tests
scripts/test.sh           Build and test on the newest iPhone simulator
.github/workflows/ci.yml  Continuous integration on a macOS runner
```

The `Soniche/` folder is a synchronized folder. Any file added there becomes part of
the app automatically, with no project file edits.
