# TurfSpot — Animated Splash Screen Plan

Reference: `TurfSpot Splash Animation Flow.png` (a storyboard of one animation, not a static screen).

## Goal

Replace the static splash with a ~2 second Flutter animation that follows the storyboard, then routes to Home if the user is logged in, otherwise to Login. Auth logic and the rest of the app stay unchanged.

## Constraints

- Colours: deep green and lime on the existing dark slate background.
- Smooth transitions, total duration about 2.0s.
- Responsive (sizes derived from screen size) and lightweight.
- No new dependencies. No image assets exist in the repo (`assets/` is missing), so everything is drawn with `CustomPaint` and built-in icons.
- Never show the reference image on screen.
- Keep code clean and in the style of the surrounding files.

## Animation timeline

One `AnimationController` of 2000 ms. Each stage is an `Interval` of it.

| # | Time | Fraction | Stage | What happens | Curve |
| --- | --- | --- | --- | --- | --- |
| 1 | 0.0–0.3s | 0.00–0.15 | Fade In | Night sky, two floodlights and grass field fade in | `easeIn` |
| 2 | 0.3–0.8s | 0.15–0.40 | Pitch Animation | Glowing lime lines draw along their paths: centre line, centre circle, both penalty-box edges | `easeInOut` |
| 3 | 0.8–1.2s | 0.40–0.60 | Logo Reveal | Pin logo scales from 40% to 100% and fades in with a glow | `easeOutBack` |
| 4 | 1.2–1.8s | 0.60–0.90 | Tagline Appears | "Turf" (white) + "Spot" (lime) and the tagline fade in, sliding up 16 px | `easeOutCubic` |
| 5 | 1.8–2.0s | 0.90–1.00 | Transition | Logo shrinks to 60%, background and lines fade out, then navigate | `easeInCubic` |

## Files

| File | Change |
| --- | --- |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Rewritten. Owns the controller, the five stage animations, layout, and navigation |
| `lib/features/auth/presentation/widgets/splash_painters.dart` | New. `StadiumBackgroundPainter`, `PitchLinesPainter`, `LogoPinPainter` |
| `lib/core/constants/app_colors.dart` | Added `lime` (`#A3E635`) and `deepGreen` (`#052E16`) |

Unchanged: `auth_provider.dart`, `auth_repository.dart`, `app_router.dart`, `pubspec.yaml`.

## Design details

- **Background painter:** vertical gradient sky, a darker-to-lighter grass gradient below a horizon at 50% of the screen height, a soft radial pool of light on the pitch, and two floodlights (radial glow, pole, 2×3 bulb grid) at 17% and 83% of the width.
- **Pitch lines:** a `Path` list built from the screen size. Each path is drawn with `PathMetric.extractPath(0, length * progress)`, once as a blurred wide glow stroke and once as a thin bright core stroke.
- **Logo:** a location-pin path with a blurred glow stroke, a deep-green fill and a lime-to-green gradient outline. A `sports_soccer_rounded` icon sits inside it.
- **Text:** `GoogleFonts.outfit` for the name and `GoogleFonts.inter` for the tagline (both already in the app). The tagline comes from `AppConstants.appTagline`.
- **Performance:** one controller, one `AnimatedBuilder`, painters repaint only when their inputs change.

## Startup flow

1. Router opens `/splash` (existing `initialLocation`).
2. `_controller.forward()` runs the timeline.
3. When it completes and the widget is still `mounted`, read `authRepositoryProvider.currentUser`.
4. User exists → `context.go('/home')`. Otherwise → `context.go('/auth')`.

## Status

| Step | State |
| --- | --- |
| Colours added | Done |
| Painters written | Done, not compiled |
| Splash screen rewritten | Done, not compiled |
| Run and compare to storyboard | **Not done** |

Flutter and Dart are not available in the shell used so far, so none of this has been compiled or seen on a screen.

## Remaining steps

1. **Unblock the build.** The other screens import `'../../../core/...'`, which points to a folder that does not exist (should be `'../../../../core/...'`). There is also no `android/` or `ios/` folder, so run `flutter create . --project-name turf_spot` first, and a missing `assets/images/` folder is declared in `pubspec.yaml`. These are existing issues outside the splash, so they need your go-ahead before I change them.
2. Run `flutter analyze` and fix anything it reports in the splash files.
3. Run the app on an emulator and compare each stage with the storyboard. Adjust the horizon height, line positions, logo size and glow strength.
4. Test on a small phone, a large phone and a tablet.
5. Check both routes: logged out goes to Login, and logged in goes to Home.
6. Check smoothness in profile mode (no dropped frames).
7. Add a widget test that pumps the splash for 2s and checks the destination route.

## Acceptance checklist

- [ ] Animation runs for about 2.0s and follows the five stages in order
- [ ] No static image is displayed
- [ ] Deep green and lime palette, smooth transitions
- [ ] Layout holds on small, large and tablet screens
- [ ] Logged-in user lands on Home, logged-out user lands on Login
- [ ] Auth logic, router and `pubspec.yaml` unchanged
- [ ] No new dependencies
- [ ] `flutter analyze` clean for the splash files
