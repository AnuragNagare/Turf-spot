# TurfSpot — APK Fix Plan (images, crowded layouts, splash)

References:
- `TurfSpot Splash Animation Flow.png` (the 5-stage splash)
- `TurfSpot Sports App Login Screen.png` and `TurfSpot Turf Discovery App UI.png` (the target login and home)
- `WhatsApp Image 2026-10-26 at 3.13.40 PM*.jpeg` (what the built APK looks like: Home, Detail, Login)

Earlier plans are kept as `plan-splash.md`, `plan-auth.md`, `plan-home.md`, `plan-detail.md` and `plan-profile.md`.

## Goal

Make the built APK look and behave like the references: the stadium splash animation plays, photos load, and nothing is cramped or clipped on a real phone with large font or display size.

## What was checked, and what was not

Flutter, `adb` and an emulator are not installed on this machine, and the repo has no `android/` or `ios/` folder, so the APK was built somewhere else. Nothing below was compiled or run. Findings come from the three APK screenshots, the reference images and the code. Anything marked **unverified** needs a run on a device.

## Findings

| # | Symptom in the APK | Cause | Evidence | Confidence |
| --- | --- | --- | --- | --- |
| 1 | Grey boxes with a whistle icon instead of turf photos (Home card, Detail header, thumbnails) | Three mock photo URLs return **HTTP 404**: `photo-1508098682722…`, `photo-1529900245534…`, `photo-1531415074868…`. The fallback in `TurfModel.coverPhoto` (`turf_model.dart:63`) is one of them. Skyline Sports Hub (`turf_4`) uses `…1508098682722…` as its cover, which is the card in the screenshot. `CachedNetworkImage` shows its `errorWidget` (`Icons.sports`) | `curl` on every URL in `mock_turfs_data.dart` | High |
| 2 | **Release builds will have no internet at all**, so every image and Google Font would fail | A Flutter project's *main* `AndroidManifest.xml` has no `INTERNET` permission; only the debug and profile manifests add it. The screenshots show the red "OVERFLOWED BY 37 PIXELS" stripe, so they are a **debug** APK and network still worked there | Screenshot text; `android/` is not in the repo, so the manifest could not be read | Medium (unverified) |
| 3 | Text and controls look big and crowded | Layouts use fixed sizes (hero 32 sp, 48 px chips, 60 px nav items) and do not limit how far the system font size can scale text (`main.dart` has no `MediaQuery` override). On a phone with large font or display zoom, everything grows and rows collide | Code; the device's font and display settings are unknown | Medium (unverified) |
| 4 | Detail screen: Call and Share are thin slivers ("Cal") | `detail_action_bar.dart:38-61` splits the row 1 : 13 : 1. At 360 dp wide, Call gets about 20 dp | Screenshot 3, code | High |
| 5 | Home card: "Covered Roofing (Mons… Saf…" runs off the card and triggers the overflow stripe | `_amenity` in `turf_card.dart:259` is a `Row` with an unbounded `Text` inside a `Wrap` | Screenshot 1, code | High |
| 6 | Login tab "Phone (OTP)" shows as "Phone (O…" | `auth_method_tabs.dart`: 24 px icon + 15 sp label in one third of the width, so about 75 dp for the text, which is tight even at normal font size | Screenshot 2, code | High |
| 7 | Splash animation not seen / not like the reference | Two separate things. (a) The current splash is drawn with shapes (`splash_painters.dart`), not the photographic stadium and pin logo in the reference, so it cannot match. (b) Whether it plays at all on the device is unknown; Android's own launch screen may be covering it | Code vs reference; no device access | (a) High, (b) unverified |

Two things in the screenshots that are **not** bugs:
- The floating nav bar cutting off the last card on Home and the "OR" under the system bar on Login are just the lists being scrolled; both screens scroll. The real problem is that large text makes content taller than needed.
- The empty grey header on Detail is finding 1, not a layout fault.

## Differences between the references and the current app (design, not bugs)

| Area | Reference | Current code |
| --- | --- | --- |
| Splash | Real night-stadium photo, glowing pitch lines, **pin logo with a ball and leaf swoosh**, "TurfSpot" and tagline, shrink to the next screen | Painted sky, grass, floodlights; pin outline with a plain football icon |
| Login hero | Stadium photo with light streaks; "PLAY MORE. SEARCH LESS." footer with a batter and a footballer | Painted stadium; `AuthFooter` exists, check it matches |
| Home hero | Stadium photo | Painted stadium |
| Bottom bar | Home, Explore, My Turfs, Profile | Home, Profile only (Explore and My Turfs were declined earlier; unchanged here) |

## Needs from you

1. **The `android/` folder.** Copy it from the machine that builds the APK into the repo root (or tell me to run `flutter create . --project-name turf_spot --platforms android,ios` after Flutter is installed). Without it I cannot fix finding 2 or the native launch screen.
2. **Splash and hero assets**, exported as separate files into `assets/images/`:
   - `stadium_night.jpg`: the night field and floodlights photo (the empty-pitch frame from stage 1 of the splash image, or a clean crop of the login hero)
   - `logo_pin.png`: the pin logo with transparent background, about 512 px
   - optional `login_footer.png`: the batter and footballer strip
   If you cannot export them, I will keep the painted splash and only polish it. It will not match the photo.
3. **One decision:** keep Home and Profile as the only two tabs, or build the 4-tab bar from the reference.

## Design decisions

1. **Limit text scaling to 1.0–1.15** for the whole app, using a `MediaQuery` override in `MaterialApp.builder`. This is the main fix for "crowded"; the cap keeps accessibility partly intact. Screens are then checked at 1.15, not at 3.0.
2. **Make rows survive narrow widths** instead of shrinking text: flexible text with ellipsis, `FittedBox(scaleDown)` for labels that must stay on one line.
3. **Detail action bar:** Call and Share become equal-width buttons beside a wider Directions button (flex 3 : 5 : 3 with `FittedBox` labels).
4. **Images:** replace dead URLs with ones that return 200, and make the fallback cover one of them. Local assets are not used for turf photos (they are network data in the real app).
5. **Splash:** photo background plus the logo asset, same 2.0 s timeline as `plan-splash.md` (fade in, pitch lines, logo, text, shrink). Keep the pitch-line painter on top of the photo.
6. **Native launch screen:** match its colour to the splash background so there is no white or black flash before Flutter draws.
7. **No new dependencies** unless `flutter_native_splash` is needed for item 6; decide when the Android project is available.

## Files

| File | Change |
| --- | --- |
| `lib/features/turfs/data/mock_turfs_data.dart` | Replace the three 404 URLs (they appear in `turf_1`, `turf_3`, `turf_4`); keep each turf's photos distinct enough |
| `lib/features/turfs/domain/turf_model.dart` | `coverPhoto` fallback → a URL that returns 200 |
| `lib/main.dart` | `MaterialApp.builder` that clamps `MediaQuery` text scaling to 1.0–1.15 |
| `lib/features/turfs/presentation/widgets/turf_card.dart` | `_amenity`: `Flexible` text with ellipsis; keep at most 2 amenities when narrow |
| `lib/features/turfs/presentation/widgets/detail/detail_action_bar.dart` | Equal-width Call and Share, wider Directions, scale-down labels |
| `lib/features/auth/presentation/widgets/auth_method_tabs.dart` | Smaller icon and `FittedBox` label so "Phone (OTP)" fits |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Photo background, logo asset, same timeline |
| `lib/features/auth/presentation/widgets/splash_painters.dart` | Keep `PitchLinesPainter`; `StadiumBackgroundPainter` becomes the fallback |
| `lib/features/auth/presentation/widgets/auth_hero.dart`, `.../home_hero.dart` | Use the stadium photo behind the existing text (only if assets are supplied) |
| `pubspec.yaml` | Nothing new unless a native-splash package is chosen |
| `android/app/src/main/AndroidManifest.xml` | Add `<uses-permission android:name="android.permission.INTERNET"/>`; set launch background colour |

Unchanged: providers, repositories, routing, profile screens.

## Implementation steps

1. **Android project.** Bring `android/` into the repo; check the main manifest for `INTERNET`; add it if missing.
2. **Images.** Replace the dead URLs and the fallback; re-run the `curl` check until every URL is 200.
3. **Text scale clamp** in `main.dart`.
4. **Overflow fixes:** turf card amenities, auth method tabs, detail action bar. Check each at 1.15 scale on a 360 dp wide screen.
5. **Splash** with the supplied assets (or a polished painted fallback), then match the native launch background.
6. **Hero images** on Login and Home if assets are supplied.
7. **Release build:** `flutter build apk --release`; install it on the phone.

## Verification

None of this has been done yet.

1. `flutter analyze` with no new warnings.
2. `flutter run` on the phone in debug: no red overflow stripes on Splash, Login (Email, Phone, Google tabs), Home, Detail, Profile.
3. On the phone, set Settings → Font size to the largest value and Display → Screen zoom to the largest value; repeat step 2. With the clamp, text should stay at most 1.15× and nothing should clip.
4. **Release APK (not debug):** images and fonts load; confirms the `INTERNET` permission.
5. Cold start: splash plays for about 2 s with all five stages, then goes to Login (logged out) or Home (logged in). Record a screen capture to confirm the frames match the reference.
6. Every turf in the list shows a cover photo; open each Detail and check the thumbnails.
7. Compare Login and Home with the references.

## Acceptance checklist

- [ ] All six turfs show cover photos and detail photos in a **release** APK
- [ ] No overflow stripes anywhere at maximum system font and display size
- [ ] Detail screen: Call, Directions and Share are all readable and tappable (48 px minimum)
- [ ] "Phone (OTP)" is fully visible on a 360 dp screen
- [ ] Splash shows the stadium, glowing pitch lines, logo, name and tagline, then moves on by 2.0 s
- [ ] No white or black flash between the launch screen and the splash
- [ ] No new dependencies, unless approved

## Status

| Step | State |
| --- | --- |
| Investigation (URLs checked, code and screenshots compared) | Done |
| Image URLs, text-scale clamp, card / tabs / action-bar overflow fixes | Written (not compiled) |
| Splash, Login hero, Home hero use `stadium_night.jpg` and `logo_pin.png` | Written (not compiled) |
| `INTERNET` permission, release build, device check | **Waiting on the friend who builds the APK** |
