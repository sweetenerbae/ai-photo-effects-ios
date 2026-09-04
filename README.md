# BroadAppsTestApp

This repository is prepared for public publication with placeholder configuration values only.

## Architecture

- SwiftUI screens are grouped by feature and use `@MainActor` view models for UI state.
- `AppEnvironment` is the composition root for repositories, API services, and the shared `NetworkClient`.
- Feature code depends on protocols such as `EffectsRepository`, `ImageGenService`, and `AvatarServicing`, allowing test doubles without changing views.
- `NetworkClient` owns URL construction, authorization, multipart encoding, response validation, and decoding.
- Tokens are stored in Keychain; generated-image metadata and files are stored separately.
- `PORTFOLIO_MODE = YES` keeps the public build offline and uses local demo data.

## Secrets and local configuration

- `BroadAppsTestApp/Sources/Core/Config/Debug.xcconfig` and `Release.xcconfig` currently contain demo-safe placeholder values.
- Copy `BroadAppsTestApp/Sources/Core/Config/Secrets.example.xcconfig` into a local non-tracked xcconfig file when you need real backend values.
- Never commit production API keys, signing assets, `.env` files, `GoogleService-Info.plist`, `.p8`, or provisioning profiles.

## Public repo checklist

- Keep `PORTFOLIO_MODE = YES` for screenshots, demos, and public examples.
- Replace placeholder values locally before connecting to real services.
- Rotate any real keys that may have been used in this project before publication.

## Verification

Build the public configuration without code signing:

```sh
xcodebuild -project BroadAppsTestApp.xcodeproj \
  -scheme BroadAppsTestApp \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Release \
  CODE_SIGNING_ALLOWED=NO build
```
