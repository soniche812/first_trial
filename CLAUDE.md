# SONICHE: guide for Claude Code

SONICHE is an iPhone-only AI personal stylist app written in Swift and SwiftUI.
Claude Code writes most of the code. The owner builds and runs it in Xcode on an Intel Mac.

## Facts

- Bundle ID: `com.soniche812.soniche`. Display name: SONICHE.
- Minimum iOS: 17.0. Device family: iPhone only. Portrait only.
- Swift 5 language mode. Swift tools version 5.9.

## Layout and where code goes

- `Packages/SonicheKit/Sources/SonicheKit/`: almost all code goes here, including views,
  models, services, and the stylist client. Files are picked up by directory.
  Mark anything the app shell uses as `public`. Group code by feature folder:
  `Wardrobe/` (items, on-device store, photo handling, wardrobe screens) and
  `Stylist/` (AI outfit suggestions).
- Wardrobe data lives in Application Support under `Wardrobe/`: `wardrobe.json` plus
  `Images/<item id>.jpg`. `ClothingCategory` raw values are stored on disk, so never
  rename them.
- `Packages/SonicheKit/Tests/SonicheKitTests/`: unit tests (XCTest).
- `SonicheUITests/`: UI tests that drive the app on the simulator. They launch with
  `--sample-wardrobe`, which uses sample items in a temporary folder. Screenshots they
  attach are uploaded by CI as the `screenshots` artifact.
- `Soniche/`: the thin app shell. Keep it to the `@main` entry point, assets, and
  configuration. It is an Xcode 16 synchronized folder, so new files here need no
  project file edits.
- `Soniche.xcodeproj/project.pbxproj`: avoid editing. Change it only for build
  settings, new targets, or new package dependencies. Validate edits with the
  `xcodeproj` Ruby gem (`gem install xcodeproj`) by opening and re-saving the project.

## Building and testing

- Cloud sessions run on Linux with no Swift toolchain, so code cannot be compiled there.
- GitHub Actions (`.github/workflows/ci.yml`) is the compiler of record. After every push,
  check the CI run and fix failures before reporting work as done.
- On a Mac: `./scripts/test.sh` builds the app and runs all tests on the newest
  iPhone simulator.

## Rules

- Never commit secrets. API keys go in gitignored files such as `Secrets.xcconfig`,
  never in source files.
- Prefer Apple frameworks over third-party dependencies.
- Add tests in SonicheKit for any logic beyond plain view layout.
- Keep the app runnable on the iOS 17 simulator in both Xcode 16 and Xcode 26.
