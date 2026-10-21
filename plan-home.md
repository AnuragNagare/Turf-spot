# TurfSpot — Home Screen Redesign Plan

Reference: `TurfSpot Turf Discovery App UI.png`.
Earlier plans are kept as `plan-splash.md` and `plan-auth.md`.

## Goal

Restyle `HomeScreen` to match the reference: a night-stadium hero with the location, headline and a floating search bar, then sport chips, inline sort chips, and a list of horizontal turf cards, with a bottom navigation bar. Search, filters, sorting, the area picker and navigation to turf details keep working as they do now.

## What the reference shows (top to bottom)

| # | Area | Details |
| --- | --- | --- |
| 1 | **Hero (about 17% of height)** | Night stadium photo with floodlights and grass, dark gradient on the left for readability. Rounded bottom corners |
| 2 | **Top row** | Left: location pin, "Mumbai ⌄" and below it "Andheri West ⌄" (white). Right: circular profile avatar with a green dot at the top-right |
| 3 | **Headline** | "Find your turf" in white and "in 30 seconds" in lime, large bold, then "Cricket and Football turfs around you" |
| 4 | **Search bar** | White rounded bar floating over the hero's bottom edge, search icon, hint "Search turf, area or landmark...", and a sliders (filter) icon on the right |
| 5 | **Sport chips** | Three pills: **All Sports** (selected: dark green, white text, grid icon), **Cricket** (bat icon), **Football** (ball icon). Unselected are light grey with a border |
| 6 | **Sort row** | Label "Sort by", then chips: **Nearest** (selected: lime with a pin icon), **Price: Low to High**, **Price: High to Low** (sort-arrows icon). The row scrolls sideways (a fourth chip is cut off at the edge) |
| 7 | **Turf card** | White rounded card, **horizontal**: photo on the left (about 40% width, rounded), details on the right |
| 8 | **Card photo** | Heart button at top-right, camera icon with photo count at bottom-left (e.g. 12) |
| 9 | **Card details** | Name (bold), distance at top-right with a pin ("1.2 km"), "Area, City" in grey, sport pills (icon + name), star rating with review count "4.6 (128 reviews)", three amenity icons with labels (Parking, Changing Room, Washroom, or Cafeteria) |
| 10 | **Price strip** | Light-lime rounded bar: "₹1,200 / hour" in bold, and a dark green circular arrow button on the right |
| 11 | **Bottom navigation** | Floating white bar with four items: **Home** (selected: dark green pill with white icon and label), **Explore**, **My Turfs**, **Profile** |
| 12 | **Page background** | Light off-white, cards separated by small gaps |

Colours seen: deep forest green (selected chips, nav pill, arrow button), lime (headline, selected sort chip), light lime (price strip), off-white page, white cards.

## Gaps between the current screen and the reference

| Area | Current code | Reference |
| --- | --- | --- |
| Theme | Dark slate page and dark cards | Dark hero, then a **light** page with white cards |
| Header | Plain row: "Mumbai" + area, avatar | Photo hero with headline, subtitle, green-dot avatar |
| Search | Dark bar, placeholder "Search by turf name or area..." | White floating bar overlapping the hero, sliders icon, new hint text |
| Sport chips | Present (All Sports, Cricket, Football) in dark style | Same three, restyled (dark green selected) |
| Sort | Button that opens a bottom sheet | Inline chips with "Sort by" label |
| Turf card | **Vertical**: 180 px photo on top, sports badge and distance over the image, details below | **Horizontal**: photo left, details right |
| Card content | Name, area, sports, distance, price | Adds heart, photo count, rating, amenities, price strip with arrow |
| Bottom nav | None | Home / Explore / My Turfs / Profile |
| List status | "Nearby Turfs" heading and "N available" | Not shown in the reference |

## Items in the reference that the app does not support yet

These need a decision before building (see Open questions). The plan gives a default for each so work is not blocked.

| Item | Why it is a gap | Default in this plan |
| --- | --- | --- |
| **Star rating and review count** | `TurfModel` has no rating, and the PRD lists user ratings and reviews as a non-goal for v1 | Add optional `rating` and `reviewCount` to the model and mock data, set by the TurfSpot team; show them only when present. No user review submission |
| **Heart / favourites** | Favourites are v2 scope in the PRD; no state or storage exists | Heart is shown and toggles a local favourites set held in a Riverpod provider (in memory for now). Persistence comes with the backend |
| **Photo count badge** | Not a model field | Derive from `photos.length` |
| **Amenity icons on the card** | Data exists (`amenities`), only the card does not show it | Show the first three amenities with icons; reuse the icon mapping from the detail screen |
| **Filter (sliders) icon in search bar** | No filters beyond sport, sort and area | Opens the existing area picker for now |
| **Explore and My Turfs tabs** | No such screens; booking is out of scope | Keep four tabs. **Explore** shows the same list focused on search; **My Turfs** shows the favourites list. Both are simple first versions and can be removed if you want a smaller bar |
| **Avatar green dot** | No presence or notification concept | Decorative only |
| **Real photos** | No image assets in the repo | Keep the existing Unsplash URLs through `cached_network_image`; hero is painted in code (reusing the stadium painter) |

## Design decisions

1. **Scope: home screen and the shared bottom bar.** The rest of the app keeps its current theme. Home uses the light palette added for auth (`authSheet`, `authForest`, `lime`) plus a few new constants.
2. **No new dependencies.**
3. **Hero** is painted with the existing `StadiumBackgroundPainter`, with a left-to-right dark gradient so the white text is readable, rounded bottom corners, and the search bar overlapping its bottom edge.
4. **Sort moves inline** (chips), keeping `turfSortOptionProvider` and `TurfSortOption`. `sort_bottom_sheet.dart` stays in the repo, unused by Home, unless you want it removed.
5. **Card becomes horizontal.** `TurfCard` is rewritten; its `/turf/:id` navigation is unchanged. Tapping anywhere on the card or on the arrow opens the detail screen.
6. **Bottom navigation** is a floating bar. With go_router, use a `StatefulShellRoute.indexedStack` so `/home`, `/explore`, `/my-turfs` and `/profile` become tabs. `/turf/:id`, `/auth` and `/splash` stay outside the shell.
7. **Location text:** "Mumbai" comes from `AppConstants.defaultCity` and the area from `selectedAreaProvider`. Tapping either opens the area picker, as today.
8. **States are kept:** loading skeletons (restyled for light cards), empty state with "Clear Filters", error with Retry, pull to refresh.
9. **Search behaviour is unchanged:** 300 ms debounce, 2+ characters, matching name, area and keywords.

## Files

| File | Change |
| --- | --- |
| `lib/features/turfs/presentation/screens/home_screen.dart` | Rewrite layout: hero, search, chips, sort row, list. Keep the debounce, refresh and provider wiring |
| `lib/features/turfs/presentation/widgets/home_hero.dart` | New. Stadium hero, location row, avatar with dot, headline, subtitle |
| `lib/features/turfs/presentation/widgets/home_search_bar.dart` | New. Floating white search field with sliders icon |
| `lib/features/turfs/presentation/widgets/sport_filter_chips.dart` | Restyle to the reference (dark green selected) |
| `lib/features/turfs/presentation/widgets/sort_chips_row.dart` | New. "Sort by" label and horizontally scrolling chips |
| `lib/features/turfs/presentation/widgets/turf_card.dart` | Rewrite as the horizontal card with heart, photo count, rating, amenities and price strip |
| `lib/features/turfs/presentation/widgets/amenity_icon.dart` | New. Shared amenity name-to-icon mapping, also used by the detail screen |
| `lib/features/turfs/domain/turf_model.dart` | Add optional `rating` and `reviewCount` (keep `fromMap` and `copyWith` in step) |
| `lib/features/turfs/data/mock_turfs_data.dart` | Add rating, review counts and amenities matching the reference (KickZone Turf, PlayArena, The Turf Club, GameOn Turf) |
| `lib/features/turfs/presentation/providers/turf_provider.dart` | Add a favourites `StateNotifierProvider<Set<String>>` |
| `lib/core/widgets/shimmer_loading.dart` | Light, horizontal skeleton card |
| `lib/core/widgets/app_bottom_nav.dart` | New. Floating bottom bar with the selected dark green pill |
| `lib/core/router/app_router.dart` | Add the shell route with the four tabs |
| `lib/features/turfs/presentation/screens/explore_screen.dart`, `my_turfs_screen.dart` | New, simple (see defaults above) |
| `lib/core/constants/app_colors.dart` | Add `lime-tint` (price strip), card border and shadow colours |

Unchanged: auth files, repository interfaces, `turf_repository.dart` filtering and sorting, the detail screen (except using the shared amenity icon helper).

## Implementation steps

1. **Model and data.** Add `rating` and `reviewCount` to `TurfModel` and update the mock turfs. Add the favourites provider.
2. **Colours.** Add the new constants.
3. **Shared pieces.** `amenity_icon.dart` (moved out of the detail screen), light shimmer skeleton.
4. **Hero.** `HomeHero` with the painted stadium, left gradient, location row, avatar and green dot, headline with the lime second line, subtitle. Respect the status bar inset. Height about 17–20% of the screen, with a minimum.
5. **Search bar.** Floating white field overlapping the hero by about half its height, wired to the existing debounce and clear logic.
6. **Chips.** Restyle `SportFilterChips`; build `SortChipsRow` bound to `turfSortOptionProvider` (selected chip is lime with a pin icon).
7. **Card.** Rewrite `TurfCard`: image with heart and photo count, details column, price strip with arrow. Handle long names, missing rating, and fewer than three amenities.
8. **Home layout.** Assemble hero, search, chips, sort row and a sliver list of cards with pull to refresh; keep empty, error and loading states.
9. **Navigation.** Build the shell route and `AppBottomNav`; move Home and Profile into it and add Explore and My Turfs. Check the back button and deep link `/turf/:id` still work.
10. **Responsive pass.** Check a small phone (card text must not overflow at 360 px width), a large phone and a tablet (cap content width, centre it). Check large system font sizes and 48 px tap targets.
11. **Accessibility.** `Semantics` labels on the heart, arrow and filter icon; selected state on chips and nav items.

## Behaviour that must not change

- Search, sport filter, sort and area filter results (the providers and repository are untouched).
- Tapping a card opens `/turf/:id`; tapping the avatar opens the profile.
- Pull to refresh, the empty state with "Clear Filters", and error with Retry.
- The sport filter still follows the preferred sport chosen in Profile.

## Verification

Flutter is not installed in the shell used so far, so none of this can be compiled or viewed from there. Before calling it done:

1. Install Flutter and run `flutter create . --project-name turf_spot --platforms android,ios` (no `android/` or `ios/` folder exists yet).
2. `flutter analyze` with no errors in the touched files.
3. Run on an emulator and compare to the reference section by section.
4. Walk through: search with a typo-free name, each sport chip, each sort chip, area change, empty result, offline or error state, favourite toggle, opening a turf and coming back, all four tabs.
5. Widget tests: a card renders name, distance, price and amenities; tapping a sort chip changes the order; the empty state clears filters; the bottom bar switches tabs.

## Acceptance checklist

- [ ] Hero with location row, avatar, two-colour headline and subtitle
- [ ] Floating search bar overlapping the hero, with the sliders icon
- [ ] Sport chips and inline sort chips in the reference style
- [ ] Horizontal turf cards with heart, photo count, rating, amenities and price strip
- [ ] Floating bottom bar with Home, Explore, My Turfs and Profile
- [ ] Existing search, filter, sort, area and navigation behaviour unchanged
- [ ] Loading, empty and error states restyled and working
- [ ] No new dependencies; the reference image is never shown in the app
- [ ] No overflow on small screens or large text sizes

## Decisions (confirmed)

- **Ratings:** shown, using mock data (`rating` and `reviewCount` on the mock turfs).
- **Favourites:** built, local to the session (a Riverpod provider; not saved across restarts).
- **Bottom bar:** no Explore or My Turfs. Built with Home and Profile only (Profile opens `/profile`; the router is unchanged).
- **Filter icon:** opens a sheet listing four placeholder options (Price range, Amenities, Rating, Distance) marked "Coming soon". They do nothing yet.
- **Artwork:** none supplied, so the hero is painted in code.

## Status

| Step | State |
| --- | --- |
| Model and mock data (`rating`, `reviewCount`), favourites provider | Written |
| `home_hero`, `home_search_bar`, `sort_chips_row`, `filter_options_sheet`, `amenity_icon`, `app_bottom_nav` | Written |
| `sport_filter_chips`, `turf_card` (horizontal), light skeleton and empty state | Written |
| `home_screen.dart` rewritten | Written |
| `flutter analyze`, run on a device, visual comparison, widget tests | **Not done** (Flutter is not installed in this shell) |
