# TurfSpot — Turf Details Screen Redesign Plan

Reference: `KickZone Turf Booking App.png` (the screen shown when a user taps a turf card on Home).
Earlier plans are kept as `plan-splash.md`, `plan-auth.md` and `plan-home.md`.

## Goal

Restyle `TurfDetailScreen` (`/turf/:id`) to match the reference: a full-width photo header with a counter and a thumbnail strip, then the turf's identity, quick specs, a three-column pricing card, opening hours with an Open Now chip, an amenities grid, and a bottom bar with Call, Directions and Share. The existing actions (dialer, Google Maps directions, share sheet), data loading and error states keep working.

The file name says "Booking App", but the screen has no booking button. Booking stays out of scope for v1.

## What the reference shows (top to bottom)

| # | Area | Details |
| --- | --- | --- |
| 1 | **Photo header (about 25% of height)** | Full-bleed cover photo under the status bar. Top-left: dark green circular **back** button with a white arrow. Top-right: two white circular buttons, **heart** (favourite) and **share**. Bottom-right: dark pill with a camera icon and **"1 / 12"** counter |
| 2 | **Thumbnail strip** | Row of 5 equal rounded tiles under the photo. The selected tile has a lime border. The last tile is dimmed with **"+8"** (the remaining photos) |
| 3 | **Title** | "KickZone Turf", large bold |
| 4 | **Location row** | Left: pin icon and "Andheri West, Mumbai". Right: map icon and "1.2 km" |
| 5 | **Rating row** | Gold star, **4.6** (bold), "(128 reviews)" in grey, a light-green **Popular** badge with a verified icon. Right-aligned: check icon and "Info updated on 18 Oct 2026" |
| 6 | **Sport pills** | Grey pills with icon: Football, Cricket |
| 7 | **Specs row** (between thin dividers) | Three columns, icon + small grey label + value: **Turf Type** (grass icon) "Artificial Grass"; **Formats** (pitch icon) "5v5, 7v7, 9v9 / Box Cricket"; **Surface** (layers icon) "Synthetic Turf" |
| 8 | **Pricing card** | Light green rounded card titled "₹ Pricing (Per Hour)". Three columns separated by thin dividers: **Weekday** (calendar icon, "Mon – Fri") ₹1,000 / hour; **Weekend** (calendar icon, "Sat – Sun") ₹1,300 / hour; **Peak Hours** (bolt icon, "6 PM – 11 PM") ₹1,500 / hour |
| 9 | **Opening hours card** | White card: clock icon, "Opening Hours", "6:00 AM – 12:00 AM", and a green **Open Now** chip on the right |
| 10 | **Amenities** | Heading with grid icon. Grid of white tiles, **5 per row**, icon above a one or two line label. Ten shown: Parking, Changing Room, Washroom, Cafeteria, Drinking Water, Seating Area, Flood Lights, Safety Net, Box Cricket, Football Goals |
| 11 | **Sticky bottom bar** | White bar, top corners rounded, three equal buttons: **Call** (white, dark outline, phone icon), **Directions** (dark green filled, white text, navigation icon), **Share** (light-lime fill, share icon) |
| 12 | **Page background** | Light off-white (`authSheet`), same palette as the auth and home screens |

Colours: deep forest green (back button, Directions), lime (selected thumbnail, light-lime Share and pricing tint), off-white page, white cards.

## Gaps between the current screen and the reference

| Area | Current code (`turf_detail_screen.dart`) | Reference |
| --- | --- | --- |
| Theme | Dark slate page and dark cards | Light page, white and light-green cards |
| Photos | Swipeable carousel with dot indicators | Swipeable photo plus a counter ("1 / 12") and a **thumbnail strip** with "+N" |
| Header buttons | Back and Share only (black circles) | Green back, white **heart** and **share** |
| Title block | Name and area badge, distance badge, freshness tag | Name, location with distance, **rating, reviews, Popular badge**, freshness text, sport pills |
| Specs | Surface pill, formats as pills | Three labelled columns: **Turf Type, Formats, Surface** |
| Pricing | Vertical list built from the `priceDetails` map | Fixed **three-column card**: Weekday, Weekend, Peak Hours, each with a sub-label |
| Opening hours | Daily rows from the `openingHours` map | One summary line with an **Open Now** chip (live status) |
| Amenities | Wrapped grid with a few icons | **5-column tile grid**, more icons (seating, safety net, cafeteria, goals, box cricket) |
| Map preview | Placeholder map card in the body | Not visible in the reference; the screen scrolls beyond the amenities, so it is kept at the bottom |
| Bottom bar | Call Turf and Directions only | **Call, Directions and Share**, in the reference styles |

## Data the reference needs that the model does not have

`TurfModel` today: `surface` (one string), `formats`, `priceDetails` and `openingHours` (free-text string maps), `amenities`, `photos`, `rating`/`reviewCount` (added for Home), `updatedAt`. Defaults below keep the work unblocked.

| Item | Default in this plan |
| --- | --- |
| **Turf Type vs Surface** (two values) | Add optional `turfType` (for example "Artificial Grass") alongside `surface` ("Synthetic Turf"). If `turfType` is missing, show only the Surface column |
| **Weekday, Weekend, Peak rates** | Add optional `weekdayRate`, `weekendRate`, `peakRate` (int) and `peakHours` (String, e.g. "6 PM – 11 PM"). If they are missing, fall back to rendering the existing `priceDetails` map as rows |
| **Opening hours summary and Open Now** | Keep the `openingHours` map. Pick today's entry to show the summary line; tapping the card expands to the full week (the PRD asks for per-day hours). Open Now is computed with a small parser that handles times like "6:00 AM - 1:00 AM" and ranges that cross midnight. If a value cannot be parsed, the chip is hidden |
| **Popular badge** | Add optional `isPopular` (bool, set by the TurfSpot team in data). Shown only when true |
| **Photo counter and "+N"** | Derived from `photos.length` |
| **Date format "18 Oct 2026"** | Add a `d MMM yyyy` formatter to `AppFormatters`, next to the existing `MMM d, yyyy` |
| **More amenity icons** | Extend `amenity_icon.dart` with Seating Area, Safety Net, Cafeteria, Football Goals, Box Cricket |
| **Mock data** | Update the first mock turf to match the reference (name "KickZone Turf", rates 1,000 / 1,300 / 1,500, Peak 6 PM – 11 PM, ten amenities, `isPopular`, `turfType`). Photos stay as the real URLs available, so the counter shows the real count (the reference's "12" cannot be reproduced without 12 image URLs) |

## Design decisions

1. **Scope: the detail screen only**, plus small additions to shared helpers. No new dependencies.
2. **Photos:** a `PageView` for the header photo plus a thumbnail strip. Tapping a thumbnail jumps to that photo; the selected one gets a lime border; the counter reads "n / total". The "+N" tile opens a full-screen gallery (swipe and pinch-to-zoom with `InteractiveViewer`, no package). With 5 or fewer photos, no "+N" tile is shown. With one photo, the strip is hidden.
3. **Heart** uses the existing `favouriteTurfsProvider` from Home, so the favourite state is shared between the card and the detail screen.
4. **Back** keeps working with the router (`context.pop()` when possible, otherwise `context.go('/home')`, so a deep link does not dead-end).
5. **Pricing card** shows three columns. A column is hidden if its rate is missing, and the card uses the fallback rows if all three are missing.
6. **Responsive:** the amenities grid is 5 columns on normal phones and 4 on very narrow ones (under 340 px) so labels stay readable; the specs row wraps to rows on narrow screens; content is width-capped and centred on tablets.
7. **Bottom bar** is part of the screen (not scrolling), and the scroll content gets matching bottom padding so nothing hides behind it.
8. **Actions unchanged in behaviour:** Call uses `tel:`, Directions opens `https://www.google.com/maps/dir/?api=1&destination=lat,lng`, Share uses `share_plus` with the same message text. Failure snackbars stay.
9. **Loading and errors:** the existing "Turf Not Found" and error states are restyled light; a light skeleton replaces the spinner while loading.

## Files

| File | Change |
| --- | --- |
| `lib/features/turfs/presentation/screens/turf_detail_screen.dart` | Rewrite the layout; keep `_makeCall`, `_openDirections`, `_shareTurf` |
| `lib/features/turfs/presentation/widgets/detail/detail_photo_header.dart` | New. Photo `PageView`, back, heart and share buttons, counter pill |
| `lib/features/turfs/presentation/widgets/detail/photo_thumbnail_strip.dart` | New. Thumbnails, selected border, "+N" tile |
| `lib/features/turfs/presentation/widgets/detail/photo_gallery_page.dart` | New. Full-screen zoomable gallery opened from "+N" |
| `lib/features/turfs/presentation/widgets/detail/detail_title_block.dart` | New. Name, location and distance, rating, Popular badge, freshness text, sport pills |
| `lib/features/turfs/presentation/widgets/detail/detail_specs_row.dart` | New. Turf Type, Formats, Surface columns |
| `lib/features/turfs/presentation/widgets/detail/pricing_card.dart` | New. Three-column pricing card with fallback rows |
| `lib/features/turfs/presentation/widgets/detail/opening_hours_card.dart` | New. Summary, Open Now chip, expandable week |
| `lib/features/turfs/presentation/widgets/detail/amenities_grid.dart` | New. Five-column tile grid |
| `lib/features/turfs/presentation/widgets/detail/detail_action_bar.dart` | New. Call, Directions, Share bar |
| `lib/features/turfs/presentation/widgets/amenity_icon.dart` | Add the extra icons and a full-label helper |
| `lib/core/utils/opening_hours.dart` | New. Parse "6:00 AM - 1:00 AM", return today's entry and open/closed (handles past midnight) |
| `lib/core/utils/formatters.dart` | Add the `d MMM yyyy` date format |
| `lib/features/turfs/domain/turf_model.dart` | Add optional `turfType`, `weekdayRate`, `weekendRate`, `peakRate`, `peakHours`, `isPopular` (constructor, `copyWith`, `fromMap`) |
| `lib/features/turfs/data/mock_turfs_data.dart` | Fill the new fields for the mock turfs, starting with the KickZone-style one |
| `lib/core/constants/app_colors.dart` | Add a light-green card tint for pricing (reusing `limeTint` where it fits) |

Unchanged: auth, router, repositories and providers (except reusing `favouriteTurfsProvider`).

## Implementation steps

1. **Model and data.** Add the optional fields and update the mock turfs.
2. **Helpers.** Date formatter, amenity icons, and `opening_hours.dart` with unit tests for normal ranges, past-midnight ranges ("6:00 AM - 1:00 AM") and unparseable text.
3. **Photo header.** Back, heart and share buttons, the `PageView`, counter pill, status bar inset, a gradient behind the buttons so they stay visible on bright photos.
4. **Thumbnail strip and gallery.**
5. **Title block.** Name, location row, rating row with the Popular badge and freshness text, sport pills. Handle missing rating or distance, and long names and addresses (wrap, do not overflow).
6. **Specs row and pricing card.** Include the fallbacks.
7. **Opening hours card.** Summary, live Open Now or Closed chip, expand to the week.
8. **Amenities grid.** Tiles with icon and label, 5 columns (4 on very narrow screens).
9. **Action bar.** Wire the three buttons to the existing handlers.
10. **Assemble the screen.** `CustomScrollView` with the header, content, and the existing map preview card restyled at the bottom; bottom padding for the bar; light loading, not-found and error states.
11. **Responsive and accessibility pass.** Small phone (360 px), large phone, tablet; large system font sizes; 48 px tap targets; `Semantics` labels on the back, heart, share and gallery controls.

## Behaviour that must not change

- Tapping a card on Home opens `/turf/:id` and Back returns to the list with filters, search and scroll position intact.
- Call opens the dialer, Directions opens Google Maps with the turf's coordinates, Share opens the share sheet with the same text.
- "Turf Not Found" for an unknown id and the error state still appear.
- Distance, price and freshness values come from the same data as before.

## Verification

Flutter is not installed in the shell used so far, so none of this can be compiled or viewed from there. Before calling it done:

1. Install Flutter and run `flutter create . --project-name turf_spot --platforms android,ios` (no `android/` or `ios/` folder exists yet).
2. `flutter analyze` with no errors in the touched files.
3. Run on an emulator and compare to the reference section by section.
4. Walk through: open from Home, swipe photos, tap thumbnails and "+N", favourite from here and see it on the card, Call, Directions, Share, expand opening hours, an unknown id, large font size, and a turf with missing optional data (no rating, no rates, one photo).
5. Tests: unit tests for the opening-hours parser; widget tests that the pricing card shows three rates and falls back correctly, the Popular badge shows only when set, and the "+N" tile appears only when there are more than 5 photos.

## Acceptance checklist

- [ ] Photo header with green back button, heart, share and a "n / total" counter
- [ ] Thumbnail strip with selected border and "+N" tile that opens a gallery
- [ ] Title, location and distance, rating, Popular badge, freshness date, sport pills
- [ ] Turf Type, Formats and Surface columns
- [ ] Three-column pricing card (Weekday, Weekend, Peak Hours)
- [ ] Opening hours with a live Open Now or Closed chip and per-day expansion
- [ ] Five-column amenities grid with the extra icons
- [ ] Bottom bar with Call, Directions and Share in the reference styles
- [ ] Screens still work with missing optional data
- [ ] No new dependencies; the reference image is never shown in the app
- [ ] No overflow on small screens or large text sizes

## Decisions (confirmed)

- **Popular badge:** derived from ratings (`TurfModel.isPopular`: rating 4.5 or higher with 100+ reviews). No `isPopular` data field.
- **"+N" tile:** no gallery. It jumps to the first hidden photo. The `photo_gallery_page.dart` file in the table above is not built.
- **Opening hours:** summary only (today's line plus Open Now / Closed). No expand-to-week.
- **Mock data:** the first turf is renamed to "KickZone Turf" with the reference values.
- **Map preview:** kept at the bottom, restyled light.

## Status

| Step | State |
| --- | --- |
| Model fields (`turfType`, rates, `peakHours`, `isPopular` getter), mock data, date formatter, amenity icons, `opening_hours.dart` | Written |
| `detail_photo_header`, `photo_thumbnail_strip`, `detail_title_block`, `detail_specs_row`, `pricing_card`, `opening_hours_card`, `amenities_grid`, `detail_action_bar` | Written |
| `turf_detail_screen.dart` rewritten | Written |
| Unit tests for the opening-hours parser, `flutter analyze`, run on a device, visual comparison | **Not done** (Flutter is not installed in this shell) |
