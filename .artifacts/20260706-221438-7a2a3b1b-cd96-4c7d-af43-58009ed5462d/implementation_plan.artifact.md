# App Launch and Loading Animation Implementation Plan

This plan aims to replace the current "black screen" experience during app launch with a seamless transition from a native splash screen to an animated `SplashPage` that indicates backend loading.

## User Review Required

- **Native Splash Image**: I will use a simple color-matched background for the native splash. If you have a specific logo file (PNG/SVG) for the native splash, please provide it. Otherwise, I will use a placeholder or stick to a solid brand color.
- **Backend Loading Logic**: I will simulate a backend loading process in the `SplashPage` for now. If you have specific initialization logic (e.g., Supabase, API calls), I can integrate that.

## Proposed Changes

### Native Configuration

#### [launch_background.xml](file:///C:/Github/Commuter/frontend/android/app/src/main/res/drawable/launch_background.xml)
- Update the background color to match `AppColors.primary` (#307082).

#### [LaunchScreen.storyboard](file:///C:/Github/Commuter/frontend/ios/Runner/Base.lproj/LaunchScreen.storyboard)
- (Note: I cannot directly edit storyboard binaries effectively, but I will provide instructions or attempt a simple XML modification if possible).

---

### Core Components

#### [pubspec.yaml](file:///C:/Github/Commuter/frontend/pubspec.yaml)
- Add `flutter_native_splash` if needed for better management, but I'll try manual first to avoid extra dependencies if possible.

---

### Feature: Onboarding

#### [splash_page.dart](file:///C:/Github/Commuter/frontend/lib/features/onboarding/presentation/pages/splash_page.dart)
- Convert to `StatefulWidget`.
- **Game-style Loading Bar**: Add a sleek progress bar (Material 3 `LinearProgressIndicator` or custom) near the bottom.
- **Pulsating Loading Text**: Add "Initializing Transit Data..." or similar status text above the progress bar.
- Implement an initialization sequence that simulates/handles backend loading.
- Staggered Reveal: The "Get Started" and "Log In" buttons will only fade in *after* the loading bar reaches 100%.
- Add an entry transition that matches the native splash color to avoid flickering.

---

## Verification Plan

### Manual Verification
- **Cold Boot Test**: Launch the app from a terminated state to observe the native splash screen transition.
- **Loading Phase**: Verify the `SplashPage` shows a loading state before the "Get Started" buttons appear.
- **Landscape Test**: Ensure no overflows during the loading animation.
