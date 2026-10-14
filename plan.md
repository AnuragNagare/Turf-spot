# TurfSpot — Implementation Plan (Screen-by-Screen, Step-by-Step)

> **Current Status**: ✅ Core Flutter codebase, design system, data models, state providers, and all 5 screens fully implemented and configured.

This document outlines the complete, phased implementation plan for the **TurfSpot** mobile application based on the [Product Requirements Document](file:///d:/Git%20hub%20project/Turf%20spot/TurfSpot%20%E2%80%94%20Product%20Requirements%20Document.md).

---

## Architecture & Project Structure Overview

The project follows a **Feature-First Clean Architecture** with **Riverpod** for state management and **go_router** for navigation.

```text
lib/
├── core/
│   ├── constants/           # Colors, dimensions, asset paths, API keys
│   ├── theme/               # Light/Dark themes, typography (Outfit/Inter), button/input styles
│   ├── router/              # go_router definitions and auth redirect guards
│   ├── network/             # Connectivity checker, base client utilities
│   ├── utils/               # Debouncer, formatters, validators, permissions
│   └── widgets/             # Reusable UI (buttons, text fields, skeletons, error views)
├── features/
│   ├── auth/
│   │   ├── data/            # AuthRepository, Firebase Auth dataSource
│   │   ├── domain/          # UserEntity, AuthState
│   │   └── presentation/    # Login/Signup screens, OTP modal, Auth providers
│   ├── turfs/
│   │   ├── data/            # TurfRepository, Firestore query handlers, Geo-query
│   │   ├── domain/          # TurfModel, PriceDetails, OpeningHours, Amenities
│   │   └── presentation/    # Home screen, turf card, search bar, Turf Details screen
│   └── profile/
│       ├── data/            # ProfileRepository (Firestore update, image upload)
│       ├── domain/          # UserProfile update models
│       └── presentation/    # Profile screen, Edit profile modal, Settings
└── main.dart                # App entry point, Firebase init, ProviderScope
```

---

## Phase 0: Foundation & Environment Setup

### Step 0.1: Project Initialization & Dependency Configuration
- Initialize Flutter project targeting Android 8.0+ and iOS 14+.
- Configure `pubspec.yaml` with core packages:
  - **State & Routing**: `flutter_riverpod`, `go_router`
  - **Firebase**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_analytics`, `firebase_crashlytics`
  - **Location & Maps**: `geolocator`, `google_maps_flutter`, `geoflutterfire_plus`
  - **UI & Utilities**: `cached_network_image`, `shimmer`, `flutter_svg`, `url_launcher`, `share_plus`, `intl`
  - **Auth Helpers**: `google_sign_in`

### Step 0.2: Design System & Theming (`lib/core/theme/`)
- Define brand color palette (vibrant sports turf greens `#10B981`, dark accents `#0F172A`, surface cards, muted texts).
- Configure responsive typography with Google Fonts (`Outfit` or `Inter`).
- Establish global input decoration themes, elevated button themes, and card styling with 48px+ touch targets.

### Step 0.3: Routing Infrastructure (`lib/core/router/`)
- Setup `GoRouter` with defined route constants:
  - `/splash`
  - `/auth` (login & signup)
  - `/home` (root turf listing)
  - `/turf/:id` (turf details)
  - `/profile` (user profile)
- Wire redirect logic based on Riverpod's `authStreamProvider`.

---

## Phase 1: Screen 1 — Splash Screen

### Objective
Provide immediate visual feedback on cold start (<3s target) and seamlessly route users based on existing session state.

### Step-by-Step Implementation:
1. **Presentation (`features/auth/presentation/screens/splash_screen.dart`)**:
   - Create animated splash screen with TurfSpot branding and loading indicator.
2. **Session Verification Logic**:
   - Initialize Firebase and fetch `FirebaseAuth.instance.authStateChanges()`.
   - Preload cached user profile from local cache / Firestore.
3. **Route Navigation Guard**:
   - If user session is active $\rightarrow$ Navigate to `/home`.
   - If user is unauthenticated $\rightarrow$ Navigate to `/auth`.

---

## Phase 2: Screen 2 — Login and Sign-Up Screen

### Objective
Allow users to create an account or authenticate via Email/Password, Phone OTP, or Google Sign-In with robust inline validation.

### Step-by-Step Implementation:
1. **Data Layer (`features/auth/data/`)**:
   - Create `AuthRepository` implementing:
     - `signInWithEmailAndPassword(email, password)`
     - `signUpWithEmailAndPassword(name, email, password)`
     - `sendPhoneOtp(phoneNumber, onCodeSent, onVerificationFailed)`
     - `verifyPhoneOtp(verificationId, smsCode)`
     - `signInWithGoogle()`
     - `sendPasswordResetEmail(email)`
2. **State Management (`features/auth/presentation/providers/`)**:
   - Create `authControllerProvider` managing `AsyncValue<UserEntity?>`.
   - Implement toggle state between **Login** and **Sign-Up** tabs.
3. **Presentation & Form Validation (`features/auth/presentation/screens/auth_screen.dart`)**:
   - Build dual tab interface (Login / Sign-up).
   - Form fields with inline validators:
     - Name: required on sign-up.
     - Email: regex format check.
     - Phone: 10-digit numeric check.
     - Password: minimum 8 characters.
   - Build **Phone OTP Bottom Sheet / Verification Dialog** with 6-digit pin input and auto-resend countdown timer.
   - Add "Forgot Password" link triggering reset link dialog.
   - Add "Continue with Google" branded button.
   - Handle descriptive error snackbars (wrong password, user-not-found, email-already-in-use, network error).

---

## Phase 3: Screen 3 — Home Screen (Search & Turf Listing)

### Objective
The primary discovery hub where users search, filter, and view nearby sports turfs sorted by distance.

### Step-by-Step Implementation:
1. **Location Integration (`core/utils/location_service.dart`)**:
   - Implement GPS permission check via `geolocator`.
   - On grant $\rightarrow$ Obtain user latitude & longitude.
   - On denial/permanent denial $\rightarrow$ Open Area Picker fallback modal (select neighborhood/area manually).
2. **Data & Query Layer (`features/turfs/data/`)**:
   - Implement `TurfRepository.getTurfs({sportFilter, searchQuery, sortBy, userLocation, limit, lastDoc})`.
   - Distance calculation utility (Haversine formula / `geolocator.distanceBetween`).
   - Query filters: `isActive == true`, matching `sports` array (`cricket`, `football`), and prefix match on `nameLowercase`.
3. **State Management (`features/turfs/presentation/providers/`)**:
   - `turfListNotifierProvider`: Infinite-scrolling paginated list (20 per page).
   - `searchQueryProvider`: 300ms debounced text stream.
   - `selectedSportFilterProvider`: Enum state (`Both`, `Cricket`, `Football`), initialized with user's preferred sport.
   - `sortByProvider`: Enum state (`Nearest`, `Price: Low to High`, `Price: High to Low`).
4. **Presentation (`features/turfs/presentation/screens/home_screen.dart`)**:
   - **Header & Location Bar**: Displays current detected area with a tap-to-change button and profile avatar avatar leading to `/profile`.
   - **Search Bar**:
     - Sticky top input with clear icon.
     - Triggers live search on 2+ characters with debouncing.
   - **Filter & Sort Chips**:
     - Horizontal scrolling chips for sports: `All`, `Cricket`, `Football`.
     - Dropdown / bottom sheet for sort options (`Nearest`, `Price low to high`, `Price high to low`).
   - **Turf Card (`widgets/turf_card.dart`)**:
     - Cached cover photo with rounded corners and aspect ratio.
     - Badge tags: sports supported (`Cricket`, `Football`).
     - Title, area name, calculated distance (`X.X km away`).
     - Starting price (`₹XXX / hr`).
     - Tap handler navigating to `/turf/:id`.
   - **List Handling & States**:
     - Shimmer skeleton cards during initial load.
     - Pull-to-refresh (`RefreshIndicator`).
     - Infinite scroll trigger at 80% scroll depth.
     - Empty search state: "No turfs found" with a "Clear search" CTA.
     - Offline banner when internet is unavailable.

---

## Phase 4: Screen 4 — Turf Details Screen

### Objective
Present comprehensive details for a specific turf, allowing players to review facilities and take immediate action (Call, Directions, Share).

### Step-by-Step Implementation:
1. **Data Layer (`features/turfs/data/`)**:
   - Implement `TurfRepository.getTurfById(turfId)`.
2. **Presentation (`features/turfs/presentation/screens/turf_detail_screen.dart`)**:
   - **Photo Carousel**:
     - PageView with smooth dot indicators showing all turf photos with pinch-to-zoom support.
     - Back button & Favorite/Share button overlaid on the app bar.
   - **Header Section**:
     - Turf name, full address, area badge, distance badge.
     - "Info updated on [Date]" freshness indicator.
   - **Specs & Surface Info**:
     - Surface pill (Artificial Grass / Natural Grass).
     - Formats supported (e.g. Box Cricket, 5-a-side, 7-a-side).
   - **Pricing Matrix Card**:
     - Base hourly price.
     - Detailed breakdown table: Weekday rates, Weekend rates, Peak-hour rates.
   - **Operating Hours Accordion**:
     - Daily schedule (Mon–Sun) with an "Open Now" / "Closed" real-time status chip.
   - **Amenities Grid**:
     - Icons + labels for: Floodlights, Parking, Changing Rooms, Washrooms, Drinking Water, Equipment on Rent.
   - **Map Preview**:
     - Embedded static/interactive map preview showing the pin on turf coordinates.
   - **Sticky Bottom Action Bar**:
     - **Call Button**: Opens system phone dialer (`tel:<phone>`) via `url_launcher`.
     - **Get Directions Button**: Launches Google Maps navigation (`https://www.google.com/maps/dir/?api=1&destination=lat,lng`).
     - **Share Button**: Native sheet sharing turf name, address, and deep link via `share_plus`.

---

## Phase 5: Screen 5 — Profile Screen

### Objective
Allow the user to view/edit their profile, configure their preferred sport, manage permissions, and handle session actions.

### Step-by-Step Implementation:
1. **Data Layer (`features/profile/data/`)**:
   - Implement `ProfileRepository`:
     - `updateUserProfile(name, preferredSport)`
     - `uploadProfilePicture(File imageFile)`
     - `deleteUserAccount()`
2. **State Management (`features/profile/presentation/providers/`)**:
   - `profileControllerProvider` syncing with Firestore user document.
3. **Presentation (`features/profile/presentation/screens/profile_screen.dart`)**:
   - **User Header**:
     - Avatar with edit overlay icon (image picker for camera/gallery).
     - Display name and email / phone number.
   - **Preferences Section**:
     - **Preferred Sport Selector**: Radio/Segmented control for `Cricket`, `Football`, or `Both`. Changing this updates the default filter on Home.
   - **Settings & Information**:
     - Location permission status tile (with quick link to OS app settings).
     - App version display (`v1.0.0`).
     - External links: Help & Support, Privacy Policy, Terms of Use.
   - **Account Actions**:
     - **Log Out**: Confirmation modal $\rightarrow$ Clear Firebase session $\rightarrow$ Navigate to `/auth`.
     - **Delete Account**: Destructive confirmation dialog with password/re-auth step $\rightarrow$ Remove Firestore record and Firebase user.

---

## Phase 6: Mock Data Seeding & Launch City Setup

### Objective
Populate Firestore with realistic launch city turfs to enable immediate testing of distance sorting, filters, search, and carousel interactions.

### Step-by-Step Implementation:
1. Create a seeding script or fixture (`assets/seed/turfs_seed.json`).
2. Populate 15–20 real/sample turfs with:
   - Accurate coordinates in the designated launch city.
   - Cover photos and gallery images (stored in Firebase Storage or high-res Unsplash links).
   - Pricing matrices, amenities arrays, and valid contact numbers.
   - Pre-computed `nameLowercase` keywords for prefix search.

---

## Phase 7: Polish, Offline Handling & Quality Assurance

### Step-by-Step Implementation:
1. **Offline & Caching**:
   - Implement Firestore local persistence.
   - Configure `cached_network_image` cache managers.
   - Add connectivity listener displaying "You are currently offline" banner.
2. **Error & Edge Case Handling**:
   - GPS disabled prompt.
   - Zero search results state with quick reset.
   - Image load fallbacks and shimmer placeholders.
3. **Audit against Non-Functional Requirements**:
   - Cold start speed measurement.
   - Minimum tap target audit (ensure all buttons $\ge 48\text{px}$).
   - Test accessibility scaling and screen reader labels.
