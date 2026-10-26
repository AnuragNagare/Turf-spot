# TurfSpot — Profile Screen Redesign Plan

Reference: `a4c80076-9593-4935-b3f9-6f7fe554fa40.png` (the profile screen, opened from the Home avatar or the Profile tab).
Earlier plans are kept as `plan-splash.md`, `plan-auth.md`, `plan-home.md` and `plan-detail.md`.

## Goal

Restyle `ProfileScreen` (`/profile`) to match the reference: a stadium header with the user's photo, name, email and city; a Preferred Sport card; three grouped menu cards (account, info, session); and the bottom navigation bar. Existing behaviour (change preferred sport, edit name, log out, delete account) keeps working, and the menu rows the reference adds get real destinations.

## What the reference shows (top to bottom)

| # | Area | Details |
| --- | --- | --- |
| 1 | **Header (about 20% of height)** | Night stadium photo (floodlights, grass) under a dark green overlay. The bottom edge is a **curved wave** with a bright green ribbon sweeping in from both sides, blending into the off-white page |
| 2 | **Avatar** | Large circle (about 80 px radius) with a white ring, on the left. A small light-lime circular **camera badge** sits at its bottom-right |
| 3 | **Identity** | To the right of the avatar: name (white, large bold, "Deepshikha Mishra"), email (muted white), and a pin icon with the city ("Mumbai") |
| 4 | **Preferred Sport card** | Light-green rounded card. Title "Preferred Sport" (dark green bold), subtitle "This will be your default filter on Home", an **Edit ✎** action at the top-right. Below, three equal pills: **All Sports** (grid icon), **Cricket** (bat icon), **Football** (ball icon). The selected one (Football) is dark green with white text |
| 5 | **Account card** (white, rounded) | Four rows, each with an outline icon, a title, a grey subtitle and a chevron: **Edit Profile** ("Update your name, email or phone"), **Notifications** ("Manage your preferences"), **Saved Turfs** ("View your favourite turfs"), **Recently Viewed** ("Your recently viewed turfs") |
| 6 | **Info card** | **About TurfSpot** ("App version 1.0.0"), **Terms & Conditions**, **Privacy Policy**, **Help & Support** |
| 7 | **Session card** | **Log Out** ("Sign out from your account"), and **Delete Account** in red ("This action cannot be undone") with a red trash icon |
| 8 | **Bottom navigation** | Floating white bar: Home, Explore, My Turfs, **Profile** (selected, dark green pill) |
| 9 | **Page background** | Light off-white (`authSheet`), same palette as the auth, home and detail screens |

## Gaps between the current screen and the reference

| Area | Current code (`profile_screen.dart`) | Reference |
| --- | --- | --- |
| Theme | Dark slate page and dark cards | Dark hero over a light page, white and light-green cards |
| App bar | "Profile" app bar with a back arrow | No app bar; the hero is the header |
| Header | Small avatar with a tiny camera badge, name with a pencil icon, email | Large avatar with a camera badge, name, email, **city** |
| Preferred sport | Three vertical radio tiles ("Both (Cricket & Football)", "Cricket Only", "Football Only") | Three horizontal pills inside a light-green card with an **Edit** action |
| Menu | "App Settings & Info" list: Location Permission ("Allowed", hard-coded), App Version, Help & Support (snackbar), Privacy Policy and Terms of Use (empty taps) | Three grouped cards with subtitles. Adds **Edit Profile, Notifications, Saved Turfs, Recently Viewed, About**. No Location Permission row |
| Session | Full-width Log Out button and a text "Delete Account" button | Two rows in a card; Delete Account in red |
| Navigation | None | Bottom navigation bar |
| Edit name | Dialog that changes the name only | "Edit Profile" row: name, email or phone |

## What the reference needs that the app does not have yet

Defaults below keep the work unblocked. No new dependencies unless noted.

| Item | Default in this plan |
| --- | --- |
| **Camera badge (change photo)** | Needs an image picker and, later, storage. Default: the badge opens a bottom sheet with "Take photo" and "Choose from gallery" marked "Coming soon", like the Home filter sheet. No `image_picker` dependency yet |
| **City under the name** | The user has no city field. Show `AppConstants.defaultCity` ("Mumbai") |
| **Email line** | Show the email, or the phone number when the user signed up with a phone |
| **Edit Profile (name, email, phone)** | New edit sheet with the three fields and the same validation as sign-up. Needs `updateUserProfile` to accept `email` and `phone` (repository interface, in-memory implementation and `AuthController.updateProfile`) |
| **Notifications** | No notification system exists. Default: a "Coming soon" sheet |
| **Saved Turfs** | Favourites exist (`favouriteTurfsProvider`, session only). New screen `/saved-turfs` lists them with the Home `TurfCard`, with an empty state |
| **Recently Viewed** | Not tracked yet. Add a `recentlyViewedProvider` (last 10 turf ids, in memory), fed when the detail screen opens. New screen `/recently-viewed`, with an empty state |
| **About TurfSpot** | Add `AppConstants.appVersion = '1.0.0'` (no `package_info_plus`). Tapping opens `showAboutDialog` with the name, version and tagline |
| **Terms, Privacy, Help** | Real URLs are not known. Default: Help opens `mailto:support@turfspot.com` (the address already used in the app) via `url_launcher`; Terms and Privacy open a simple in-app page saying the document will be published before launch. Swap in real URLs through two constants when you have them |
| **Location Permission row** | Not in the reference, and the current value ("Allowed") is hard-coded. Default: remove it. The PRD lists a permission status under app settings, so this returns when GPS is built |
| **Bottom navigation** | The reference shows four tabs; Home currently has Home and Profile only (Explore and My Turfs were declined). Default: the same two-item bar here with Profile selected |

## Design decisions

1. **Scope: the profile screen plus the small screens it links to** (Saved Turfs, Recently Viewed, Edit Profile sheet, About dialog, placeholder sheets).
2. **Header** reuses `StadiumBackgroundPainter` with a dark green overlay, clipped with a wave-shaped `CustomClipper`, and a lime ribbon painted along the curve at both ends.
3. **Avatar** shows `photoUrl` when present (`Image.network` with an error fallback) and a person icon otherwise, inside a white ring.
4. **Preferred Sport** keeps the current logic: choosing a sport calls `updateProfile(preferredSport:)` and also sets `selectedSportFilterProvider`, so Home follows. Option labels become "All Sports", "Cricket", "Football" (the stored enum values are unchanged).
5. **Edit action on the sport card:** the pills are locked until the user taps **Edit**, which then reads **Done** (matches the reference). See the open questions.
6. **Menu cards** use one reusable `ProfileMenuCard` (rows with icon, title, optional subtitle, chevron, optional red style, inset dividers).
7. **Log Out and Delete Account** keep their confirmation dialogs (restyled light) and the same calls (`signOut`, `deleteAccount`, then `context.go('/auth')`).
8. **Navigation:** Home opens Profile with `push`. In the Profile bar, tapping Home calls `context.go('/home')` and tapping Profile does nothing. System back still returns to Home.
9. **Responsive:** content is width-capped and centred on tablets; the header's text truncates with an ellipsis on narrow screens and long names or emails; text scales with the system font size.

## Files

| File | Change |
| --- | --- |
| `lib/features/profile/presentation/screens/profile_screen.dart` | Rewrite the layout; keep the logout and delete flows and the sport-sync logic |
| `lib/features/profile/presentation/widgets/profile_header.dart` | New. Stadium header with wave, avatar, camera badge, name, email, city |
| `lib/features/profile/presentation/widgets/preferred_sport_card.dart` | New. Light-green card with the Edit / Done action and three pills |
| `lib/features/profile/presentation/widgets/profile_menu_card.dart` | New. Grouped rows with icons, subtitles, chevrons and a red variant |
| `lib/features/profile/presentation/widgets/edit_profile_sheet.dart` | New. Name, email and phone with validation |
| `lib/features/profile/presentation/widgets/coming_soon_sheet.dart` | New. Reusable placeholder (photo options, Notifications) |
| `lib/features/profile/presentation/screens/saved_turfs_screen.dart` | New. Favourite turfs list using `TurfCard` |
| `lib/features/profile/presentation/screens/recently_viewed_screen.dart` | New. Recently viewed turfs list |
| `lib/features/profile/presentation/screens/info_page_screen.dart` | New. Simple Terms / Privacy placeholder page |
| `lib/features/turfs/presentation/providers/turf_provider.dart` | Add `recentlyViewedProvider` and a provider that resolves turf ids to `TurfModel`s |
| `lib/features/turfs/presentation/screens/turf_detail_screen.dart` | Record the turf in `recentlyViewedProvider` when it loads |
| `lib/features/auth/data/auth_repository.dart` | `updateUserProfile` gains optional `email` and `phone` (interface and in-memory implementation) |
| `lib/features/auth/presentation/providers/auth_provider.dart` | `AuthController.updateProfile` passes `email` and `phone` through |
| `lib/core/constants/app_constants.dart` | Add `appVersion`, `supportEmail` |
| `lib/core/router/app_router.dart` | Add `/saved-turfs`, `/recently-viewed` and the Terms / Privacy page routes |
| `lib/core/widgets/app_bottom_nav.dart` | Reused unchanged |

Unchanged: auth screens, the repository logic for sign-in, search and filter providers.

## Implementation steps

1. **Data layer.** Extend `updateUserProfile` and `updateProfile` with `email` and `phone`; add `appVersion` and `supportEmail`; add `recentlyViewedProvider` and the id-to-turf provider.
2. **Shared widgets.** `ProfileMenuCard`, `ComingSoonSheet`.
3. **Header.** `ProfileHeader` with the clipped stadium, ribbon, avatar, camera badge and identity block. Respect the status bar inset.
4. **Preferred Sport card.** Pills, selected state, Edit / Done behaviour, wiring to the existing sport sync.
5. **Menu cards.** Build the three groups with the rows and subtitles from the reference, and connect each row:
   - Edit Profile opens the edit sheet
   - Notifications opens the placeholder
   - Saved Turfs and Recently Viewed push their screens
   - About opens the dialog
   - Terms and Privacy open the info pages
   - Help opens the mail app
   - Log Out and Delete Account keep their dialogs
6. **Edit Profile sheet.** Validate name (required), email format and 10-digit phone, and require at least one of email or phone, as in the PRD data model.
7. **New screens.** Saved Turfs and Recently Viewed with the light list style and empty states ("No saved turfs yet", "Nothing viewed yet").
8. **Recently viewed tracking.** Record on detail open: move to the front if already present, cap at 10.
9. **Assemble the screen** with the bottom bar and the loading and logged-out cases (the user can be null briefly after logout: show nothing or redirect to `/auth`).
10. **Responsive and accessibility pass.** Small phone, large phone, tablet, large fonts, 48 px tap targets, `Semantics` labels on the camera badge, the Edit action and the chevron rows.

## Behaviour that must not change

- Changing the preferred sport updates the user and the default filter on Home.
- Log Out confirms, clears the session and goes to `/auth`; Delete Account confirms, removes the account and goes to `/auth`.
- Opening Profile from the Home avatar and returning with Back works.
- Editing the name still updates it everywhere the user is shown (Home avatar, header).

## Verification

Flutter is not installed in the shell used so far, so none of this can be compiled or viewed from there. Before calling it done:

1. Install Flutter and run `flutter create . --project-name turf_spot --platforms android,ios` (no `android/` or `ios/` folder exists yet).
2. `flutter analyze` with no errors in the touched files.
3. Run on an emulator and compare to the reference section by section.
4. Walk through: change sport and check Home's filter, edit profile (valid and invalid input), favourite a turf and see it under Saved Turfs, open a turf and see it under Recently Viewed, each menu row, log out, delete account, a user with a phone and no email, a long name and email, large font size.
5. Tests: widget tests for the sport card (locked until Edit, selection updates the provider), the edit-profile validators, and the recently-viewed ordering and cap.

## Acceptance checklist

- [ ] Stadium header with wave, ribbon, large avatar, camera badge, name, email and city
- [ ] Preferred Sport card with Edit / Done and three pills, selected pill dark green
- [ ] Account, Info and Session cards with the reference rows, icons, subtitles and chevrons
- [ ] Delete Account shown in red
- [ ] Edit Profile, Saved Turfs, Recently Viewed, About, Terms, Privacy and Help each lead somewhere
- [ ] Bottom bar with Profile selected; Home returns to the list
- [ ] Log Out and Delete Account behave as before
- [ ] No new dependencies; the reference image is never shown in the app
- [ ] No overflow on small screens or large text sizes

## Decisions (confirmed)

- **Edit on the sport card:** the pills are locked until Edit is tapped (Edit then reads Done).
- **Change photo:** "Coming soon" placeholder sheet, no `image_picker`.
- **Terms and Privacy:** no real URLs, so they open placeholder pages. Help opens `mailto:support@turfspot.com`.
- **Notifications:** "Coming soon" placeholder.
- **Location Permission row:** removed.
- **Bottom bar:** Home and Profile only.

## Status

| Step | State |
| --- | --- |
| Data layer: `email`/`phone` in `updateUserProfile` and `updateProfile`, `appVersion`, `supportEmail`, `recentlyViewedProvider`, `turfsByIdsProvider` | Written |
| `profile_header`, `preferred_sport_card`, `profile_menu_card`, `edit_profile_sheet`, `coming_soon_sheet` | Written |
| `turf_ids_list_screen` (shared by Saved Turfs and Recently Viewed), `info_page_screen`, routes `/saved-turfs`, `/recently-viewed`, `/terms`, `/privacy` | Written |
| Recently-viewed tracking on the detail screen | Written |
| `profile_screen.dart` rewritten | Written |
| Tests, `flutter analyze`, run on a device, visual comparison | **Not done** (Flutter is not installed in this shell) |
