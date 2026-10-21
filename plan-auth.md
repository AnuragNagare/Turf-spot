# TurfSpot — Login and Sign-Up Screen Redesign Plan

Reference: `TurfSpot Sports App Login Screen.png`.
The splash plan that used to be here is saved as `plan-splash.md`.

## Goal

Restyle `AuthScreen` to match the reference: a night-stadium hero with the logo on top, and a light rounded sheet below holding the Login / Sign Up toggle, three sign-in method tabs, the form, and a Google button, finished with a sports footer. All existing auth behaviour, validation and routing stays as it is.

## What the reference shows (top to bottom)

| # | Area | Details |
| --- | --- | --- |
| 1 | **Hero (about 31% of height)** | Night stadium photo: two floodlights, city skyline silhouette, grass in the foreground. Bright green curved ribbons cut in from the top-right and left edges. Status bar sits on top (light icons) |
| 2 | **Brand block** | Lime location-pin logo with a football inside, then "Turf" (white) + "Spot" (lime) in heavy bold, then the tagline "Find your turf in 30 seconds" in white |
| 3 | **Bottom sheet** | Off-white background (about `#F7F8F4`), large top corners (about 32 px radius), small grey drag handle centred at the top. It overlaps the bottom of the hero |
| 4 | **Login / Sign Up toggle** | Pill-shaped, full width, grey track. Selected side is a dark green pill with white text; the other side is dark text on the track |
| 5 | **Method tabs** | Three equal tabs with icon + label: **Email** (envelope), **Phone (OTP)** (phone), **Google** (G logo). Thin dividers between them. Selected tab has dark text and a lime underline; a light grey line runs under the whole row |
| 6 | **Email form** | Label "Email" and a grey rounded field with envelope icon and hint "Enter your email". Label "Password" and a field with lock icon, hint "Enter your password", and an eye-off toggle on the right |
| 7 | **Forgot password** | Right-aligned, dark green, underlined: "Forgot Password?" |
| 8 | **Primary button** | Full width, dark green (about `#14412B`), large rounded corners (about 20 px), white "Login" centred with a right arrow at the end |
| 9 | **OR divider** | Thin lines either side of "OR" |
| 10 | **Google button** | White, full width, light border and soft shadow, multicolour Google "G" and bold "Continue with Google" |
| 11 | **Footer illustration** | Soft green-tinted scene: batsman on the left, footballer on the right, trees behind, pitch at the bottom. Centred spaced-out caps "PLAY MORE. SEARCH LESS." with a short lime underline |

Colours seen: deep forest green `#0F3D2A`–`#14412B` (buttons, selected pill), lime `#A3E635`-ish (logo, "Spot", underline, ribbons), off-white sheet, light grey fields (about `#EEF0EB`), dark text.

## Gaps between the current screen and the reference

| Area | Current code (`auth_screen.dart`) | Reference |
| --- | --- | --- |
| Theme | Dark slate page, dark cards | Dark hero + **light** sheet |
| Header | Small icon, "TurfSpot", "Welcome to TurfSpot" text | Large pin logo, two-colour wordmark, tagline over a stadium image |
| Login/Sign Up | Rectangular `TabBar`, green indicator, labels "Log In" / "Sign Up" | Pill toggle, dark green indicator, label "Login" |
| Method choice | One field accepts "email or 10-digit phone"; Google is a separate button only | Explicit **Email / Phone (OTP) / Google** tabs |
| Fields | Label above, prefix icon, dark fill, long hints | Light grey fill, short hints ("Enter your email") |
| Forgot password | Plain `TextButton`, "Forgot password?" | Underlined dark green, "Forgot Password?" |
| Primary button | Emerald, no icon | Dark green, arrow icon |
| Google button | `Icons.g_mobiledata_rounded`, dark | Real multicolour G, white button |
| Footer | None | Illustration + slogan |
| Layout | Scrolling column with a fixed 380 px tab area | Sheet that fills the lower part of the screen and scrolls when the keyboard is open |

## Design decisions

1. **Scope: the auth screen only.** The app theme stays dark; this screen uses its own light palette from new constants, so Home, Detail and Profile are not affected.
2. **No new dependencies and no image assets in the repo.** The hero, logo, footer scene and Google "G" are drawn with `CustomPaint` (same approach as the splash). If you supply real images (stadium photo, footer art, logo PNG/SVG), they go in `assets/images/` and replace the painters with no other change. The reference PNG itself must never be shown in the app.
3. **Method tabs map onto the existing logic** instead of the current "guess from the input" approach:
   - **Email tab:** email + password, calls `signInWithEmail` / `signUpWithEmail`.
   - **Phone (OTP) tab:** 10-digit phone field (with +91 prefix), a "Send OTP" action that opens the existing OTP bottom sheet, which calls `sendOtp` / `verifyOtp`.
   - **Google tab:** shows a short explanation and the Continue with Google button, calls `signInWithGoogle`. The "Continue with Google" button under "OR" also stays, as in the reference.
4. **Sign Up uses the same layout.** The Login/Sign Up pill switches the form: Sign Up adds a "Full Name" field first, the password label becomes "Create Password", and the primary button reads "Create Account". The Phone tab on Sign Up passes the name into the OTP flow like today.
5. **Keep all validation:** email regex, 10-digit phone, password of 8+ characters, required name. Messages stay inline and in snackbars.
6. **Forgot Password** keeps the existing dialog, restyled for the light sheet.
7. **Keyboard handling:** the sheet is scrollable and resizes with the keyboard so fields stay visible; the hero collapses or scrolls away when the keyboard opens.

## Files

| File | Change |
| --- | --- |
| `lib/features/auth/presentation/screens/auth_screen.dart` | Restructure: hero + sheet layout, `TabController` for Login/Sign Up and a second one for Email/Phone/Google, move logic calls to the new tabs. Keep `_handleLogin`, `_handleSignUp`, `_handleGoogleSignIn`, `_openOtpBottomSheet`, `_openForgotPasswordDialog` behaviour unchanged |
| `lib/features/auth/presentation/widgets/auth_hero.dart` | New. Stadium hero, ribbons, logo, wordmark and tagline |
| `lib/features/auth/presentation/widgets/auth_footer.dart` | New. Batsman and footballer scene and "PLAY MORE. SEARCH LESS." |
| `lib/features/auth/presentation/widgets/auth_mode_toggle.dart` | New. Login / Sign Up pill |
| `lib/features/auth/presentation/widgets/auth_method_tabs.dart` | New. Email / Phone (OTP) / Google tab row |
| `lib/features/auth/presentation/widgets/google_logo.dart` | New. Painted multicolour "G" (no asset needed) |
| `lib/features/auth/presentation/widgets/splash_painters.dart` | Reuse `LogoPinPainter` and the stadium painter for the hero and logo; extract shared bits only if it keeps the code simpler |
| `lib/core/constants/app_colors.dart` | Add `authSheet`, `authField`, `authForest`, `authText` constants |
| `lib/core/widgets/custom_text_field.dart` | Add an optional light style (fill, text and icon colours) used by this screen, with the dark default unchanged for other screens |
| `lib/core/widgets/custom_button.dart` | Add an optional trailing icon and a corner radius, with defaults unchanged |

Unchanged: `auth_provider.dart`, `auth_repository.dart`, `user_model.dart`, `app_router.dart`, `pubspec.yaml`.

## Implementation steps

1. **Colours.** Add the light-sheet constants to `AppColors`.
2. **Shared widgets.** Extend `CustomTextField` and `CustomButton` with the optional light style and trailing icon, keeping current behaviour as the default.
3. **Hero.** Build `AuthHero`: night sky and floodlights (reuse the splash painter), city skyline silhouette, grass strip, two green ribbon curves, logo pin, "Turf" + "Spot" wordmark, tagline. Height about 31% of the screen, with the status bar area respected via `SafeArea`/`MediaQuery.padding`.
4. **Sheet.** Rounded container (32 px top radius) with the drag handle, overlapping the hero by about 24 px, holding a scroll view.
5. **Mode toggle.** `AuthModeToggle` bound to the Login/Sign Up controller, with the animated dark-green pill.
6. **Method tabs.** `AuthMethodTabs` with three icon + label tabs, dividers and a lime underline that slides between them.
7. **Forms.** Build the three tab bodies:
   - Email: (name when signing up) + email + password with eye toggle, Forgot Password link (login only), primary button with arrow.
   - Phone: (name when signing up) + 10-digit phone field, "Send OTP" primary button that calls the existing `_openOtpBottomSheet`.
   - Google: short text + Continue with Google.
8. **OR divider and Google button** below the form, using the painted "G".
9. **Footer.** `AuthFooter`: soft green scene with batsman and footballer silhouettes, trees, pitch; centred slogan with the lime underline.
10. **Wire logic.** Point the buttons at the unchanged handlers. Remove the "email or phone" guessing from the login and sign-up handlers, since the active tab now decides the method, but keep the same repository calls and navigation (`context.go('/home')` on success).
11. **Restyle dialogs.** Light styling for the OTP sheet and Forgot Password dialog so they match the sheet.
12. **Loading and errors.** Primary button shows its spinner while `authControllerProvider` is loading; error and success snackbars as today.
13. **Responsive pass.** Check a small phone (height under 700), a large phone and a tablet (cap the sheet width, centre it). Check text scaling and 48 px minimum tap targets.

## Behaviour that must not change

- `/splash` → `/auth` when logged out, and success on any method goes to `/home`.
- Validation rules and error messages.
- OTP flow: send, 30 s resend timer, verify.
- Forgot Password dialog and success message.
- Google sign-in and loading state.
- Repository interface and the in-memory implementation.

## Verification

Flutter is not installed in the shell used so far, so none of this can be compiled or seen from there. Before calling it done:

1. Install Flutter, add it to PATH, and run `flutter create . --project-name turf_spot --platforms android,ios` (there is no `android/` or `ios/` folder yet).
2. `flutter analyze` with no errors in the touched files.
3. Run on an emulator and compare to the reference section by section.
4. Walk through: email login, email sign-up, phone OTP login, phone OTP sign-up, Google, forgot password, wrong password, validation errors, keyboard open.
5. Widget tests: toggle switches forms, tabs switch bodies, validators show messages, successful login navigates to `/home`.

## Acceptance checklist

- [ ] Hero with stadium, ribbons, logo, wordmark and tagline
- [ ] Light rounded sheet with drag handle overlapping the hero
- [ ] Login / Sign Up pill toggle
- [ ] Email, Phone (OTP) and Google tabs with the lime underline
- [ ] Fields, buttons, divider and Google button match the reference styling
- [ ] Footer illustration and "PLAY MORE. SEARCH LESS."
- [ ] Sign Up variant has Full Name and "Create Account"
- [ ] All existing auth logic, validation and navigation unchanged
- [ ] No new dependencies, no static image of the reference screen
- [ ] Works with the keyboard open and on small, large and tablet screens

## Decisions (confirmed)

- No artwork supplied, so the hero, logo, footer scene and Google "G" are painted in code.
- Sign Up follows the Login layout, with Full Name added and "Create Account" on the button.
- Phone tab uses a separate "Send OTP" button (no direct send from Login). The "OR" divider stays, as in the reference.

## Status

| Step | State |
| --- | --- |
| Colours, `CustomTextField(light)`, `CustomButton(trailingIcon, borderRadius)` | Written |
| `auth_hero`, `auth_footer`, `auth_mode_toggle`, `auth_method_tabs`, `google_logo` | Written |
| `auth_screen.dart` rewritten (Email / Phone / Google tabs, unchanged repository calls) | Written |
| `flutter analyze`, run on a device, visual comparison, widget tests | **Not done** (Flutter is not installed in this shell) |
