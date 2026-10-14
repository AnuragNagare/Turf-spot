class AppConstants {
  static const String appName = 'TurfSpot';
  static const String appTagline = 'Find your turf in 30 seconds';
  static const String defaultCity = 'Mumbai';
  
  // Storage & Preference Keys
  static const String prefUserKey = 'turfspot_user';
  static const String prefPreferredSport = 'turfspot_sport_pref';

  // Search Debounce
  static const int searchDebounceMs = 300;

  // Pagination
  static const int turfsPerPage = 20;

  // Fallback Launch City Areas
  static const List<String> launchAreas = [
    'All Areas',
    'Andheri West',
    'Bandra West',
    'Juhu',
    'Powai',
    'Goregaon East',
    'Malad West',
    'Chembur',
    'Dadar',
    'Thane West',
    'Navi Mumbai'
  ];
}
