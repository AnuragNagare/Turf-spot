# TurfSpot — Product Requirements Document

Oct 14, 2026 · @Anurag

## Overview

TurfSpot is a Flutter mobile app that helps players find cricket and football turfs in their city, see each turf's details, and decide where to play. Version 1 is a discovery app with four screens: login and sign-up, home with search and turf listing, turf details, and profile. Booking and payments are out of scope for v1.

**Problem.** Players find turfs through word of mouth, WhatsApp groups or scattered map listings. Prices, timings, sports offered and facilities are hard to compare in one place.

**Vision.** One place to find any turf in the city, with the details that matter before you call or show up.

## Goals, non-goals and success metrics

**Goals**

- Let a user find a nearby turf within 30 seconds of opening the app.
- List every turf in the launch city with accurate, complete details.
- Make search by turf name fast and forgiving of typos.

**Non-goals for v1**

- Slot booking, payments or cancellations.
- Turf-owner dashboard (turf data is managed by the TurfSpot team).
- Reviews, ratings submitted by users, chat or team-finding.
- Multi-city support.

**Success metrics (first 3 months after launch)**

| Metric | Target |
| --- | --- |
| Sign-up completion rate | 70% of users who open the sign-up screen |
| Turf detail views per active user per week | 3 or more |
| Searches that return at least one result | 90% |
| Day-30 retention | 25% |
| Crash-free sessions | 99.5% |

Targets are starting assumptions; revisit them after the first month of data.

## Target users

The core user is a casual player aged 16–35 who plays box cricket or 5/7-a-side football with friends and needs a turf for the evening or weekend.

| Persona | Who they are | What they need from TurfSpot |
| --- | --- | --- |
| The organiser | Books the turf for a friends' group every week | Compare price per hour, timings and location quickly; get the turf's phone number |
| The new player | Just moved to the city or started playing | Discover which turfs exist nearby and what each offers |
| The specific searcher | Already knows a turf by name | Find it by name and see its address, contact and directions |

## User flow

&#91;embedded content: TurfSpot app flow · 6 screens, 1 decision\]

A returning user lands on Home with no login step; Home is the hub that leads to turf details and the profile, and logging out returns to the login screen.

## Functional requirements

The app has four screens, plus a splash screen that checks whether the user is already logged in.

### 1. Login and sign-up

- Sign up with name, email or phone number, and password.
- Phone sign-up verifies the number with a one-time password (OTP).
- Log in with email and password, or phone and OTP.
- Optional "Continue with Google".
- "Forgot password" sends a reset link or OTP.
- Inline validation: valid email format, 10-digit phone number, password of 8+ characters.
- Stay logged in until the user logs out.
- Clear error messages for wrong password, existing account and no internet.

### 2. Home: search and turf listing

- Ask for location permission on first launch; if denied, let the user pick an area manually.
- Search bar at the top that matches turf names as the user types (results after 2+ characters, 300 ms debounce).
- Typo-tolerant, case-insensitive matching; empty state with "No turfs found" and a clear-search button.
- When the search bar is empty, show all turfs in the city, sorted by distance from the user.
- Filter chips: Cricket, Football, Both.
- Sort options: Nearest, Price low to high, Price high to low.
- Each turf card shows: cover photo, name, area, distance in km, sports offered, starting price per hour.
- Pull to refresh; load 20 turfs at a time with infinite scroll.
- Skeleton loaders while data loads; an error state with Retry.

### 3. Turf details

- Photo carousel.
- Name, full address, area and distance.
- Sports offered, and turf size or format (e.g. box cricket, 5-a-side, 7-a-side).
- Surface type (artificial grass, natural grass).
- Price per hour, with weekday, weekend and peak-hour rates where they differ.
- Opening hours for each day.
- Amenities: floodlights, parking, changing rooms, washrooms, drinking water, equipment on rent.
- Buttons: Call (opens the dialler), Get directions (opens Google Maps), Share.
- Small map preview of the turf's location.

### 4. Profile

- Show name, email or phone, and profile photo.
- Edit name and profile photo.
- Preferred sport (Cricket, Football, Both), used as the default filter on Home.
- App settings: location permission status, app version.
- Links: Help and support, Privacy policy, Terms of use.
- Log out, and Delete account (with a confirmation step).

## Data model

Two collections cover v1: users and turfs.

**User**

| Field | Type | Notes |
| --- | --- | --- |
| id | string | From the auth provider |
| name | string | Required |
| email | string | Optional if phone is given |
| phone | string | Optional if email is given |
| photoUrl | string | Optional |
| preferredSport | enum | cricket, football, both |
| createdAt | timestamp |  |

**Turf**

| Field | Type | Notes |
| --- | --- | --- |
| id | string |  |
| name | string | Indexed for search |
| nameLowercase / searchKeywords | string / list | For prefix and partial-match search |
| address, area, city | string |  |
| location | geopoint | Latitude and longitude, for distance sorting |
| sports | list | cricket, football |
| formats | list | e.g. box cricket, 5-a-side, 7-a-side |
| surface | string | Artificial or natural grass |
| pricePerHour | number | Starting price in ₹ |
| priceDetails | map | Weekday, weekend, peak-hour rates |
| openingHours | map | Open and close time per day |
| amenities | list | floodlights, parking, washroom… |
| photos | list of URLs | First photo is the cover |
| phone | string | Contact number |
| isActive | boolean | Hide closed or unverified turfs |
| updatedAt | timestamp | Shown as "Info updated on…" |

## Non-functional requirements

- **Platforms:** Android 8.0+ and iOS 14+ from a single Flutter codebase.
- **Performance:** cold start under 3 seconds on a mid-range phone; listing loads in under 2 seconds on 4G; search results update in under 500 ms.
- **Images:** compressed and cached; thumbnails on cards, full size only on the details screen.
- **Offline:** show the last loaded listing with an "You're offline" banner.
- **Security:** passwords never stored by the app; all traffic over HTTPS; database rules so users can only read turfs and edit their own profile.
- **Privacy:** location used only to sort by distance and never stored on the server; a clear privacy policy; account deletion removes user data.
- **Accessibility:** text scales with system font size; tap targets at least 48 px; screen-reader labels on icons.
- **Analytics and crashes:** track sign-up, search, turf view, call and directions taps; crash reporting on from day one.

## Tech stack and architecture

Recommended: Flutter on the front end with Firebase as the backend, because it covers auth, database, image storage and analytics without running your own server.

| Layer | Choice | Why |
| --- | --- | --- |
| App | Flutter (Dart) | One codebase for Android and iOS |
| State management | Riverpod (or Bloc) | Testable, scales past v1 |
| Navigation | go\_router | Simple routes and auth redirects |
| Auth | Firebase Authentication | Email, phone OTP and Google sign-in built in |
| Database | Cloud Firestore | Real-time, easy queries, free tier for an MVP |
| Images | Firebase Storage + cached\_network\_image | Turf photos with on-device caching |
| Location | geolocator + geoflutterfire\_plus | Current location and distance sorting |
| Maps and actions | google\_maps\_flutter, url\_launcher | Map preview, Call and Directions buttons |
| Search | Firestore prefix search for v1; Algolia or Typesense later | Upgrade when typo-tolerant search is needed at scale |
| Analytics | Firebase Analytics + Crashlytics | Usage tracking and crash reports |

**Code structure (feature-first):** `lib/features/auth`, `lib/features/turfs` (listing, search, details), `lib/features/profile`, plus `lib/core` for theme, routing and shared widgets. Each feature has `data` (repositories), `domain` (models) and `presentation` (screens and widgets).

Alternative backend: Supabase (Postgres) if you prefer SQL and PostGIS for location queries.

## MVP scope, milestones and future scope

The MVP is the four screens above, live in one city, in about 8 weeks for a solo developer or a small team.

1. **Week 1 — Setup and design:** Figma wireframes for all screens, Flutter project, Firebase project, theme and routing.
2. **Week 2 — Auth:** sign-up, login, OTP, Google sign-in, forgot password, persistent session.
3. **Weeks 3–4 — Listing and search:** turf data in Firestore, location permission, distance sorting, cards, filters, search.
4. **Week 5 — Turf details:** photo carousel, details, map preview, Call, Directions and Share.
5. **Week 6 — Profile:** view and edit profile, preferred sport, logout, delete account.
6. **Week 7 — Data and polish:** collect and verify details and photos for the launch city's turfs; empty, error and offline states.
7. **Week 8 — Test and release:** testing on real devices, beta with 20–30 players, Play Store and App Store submission.

**Future scope (v2 and later)**

- Slot booking and online payments (UPI).
- Turf-owner app or dashboard to manage listings and availability.
- Ratings and reviews from players.
- Favourites and recently viewed turfs.
- Map view of all turfs.
- Find players or teams for a match.
- More cities.

## Risks and open questions

The biggest risk is data, not code: the app is only useful if turf details are complete and current.

| Risk | Mitigation |
| --- | --- |
| Turf details (prices, hours) go out of date | Show "Info updated on"; re-verify every turf monthly; add a "Report wrong info" button |
| Too few turfs listed at launch | Visit or call turfs in the launch city before release; launch in one city only |
| Users expect booking | Make the Call button prominent; put booking on the v2 roadmap |
| Search misses typos with Firestore prefix search | Store lowercase keywords; move to Algolia or Typesense if search success falls below 90% |
| OTP SMS costs grow | Make email sign-up the default; watch Firebase phone-auth usage |

**Open questions**

- [ ] Which city is the launch city?
- [ ] Should users browse turfs before logging in, or is login required first?
- [ ] Phone OTP, email, Google — which sign-in methods are in v1?
- [ ] Who collects and maintains turf data, and how often?
- [ ] Will turf owners pay to be listed or featured later?
