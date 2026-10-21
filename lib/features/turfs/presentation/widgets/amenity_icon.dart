import 'package:flutter/material.dart';

/// Icon for an amenity name such as "Car Parking" or "Changing Rooms".
IconData amenityIcon(String amenity) {
  final lower = amenity.toLowerCase();
  if (lower.contains('light')) return Icons.flash_on_rounded;
  if (lower.contains('park')) return Icons.local_parking_rounded;
  // Check "wash" before "room" so "Washroom" is not read as "Changing Room".
  if (lower.contains('wash')) return Icons.shower_outlined;
  if (lower.contains('room') || lower.contains('chang')) return Icons.checkroom_rounded;
  if (lower.contains('water')) return Icons.water_drop_outlined;
  if (lower.contains('cafe')) return Icons.restaurant_rounded;
  if (lower.contains('seat')) return Icons.weekend_rounded;
  if (lower.contains('safety') || lower.contains('net')) return Icons.verified_user_outlined;
  if (lower.contains('goal')) return Icons.sports_soccer_rounded;
  if (lower.contains('cricket') || lower.contains('rent') || lower.contains('equip') || lower.contains('bat')) {
    return Icons.sports_cricket_rounded;
  }
  return Icons.check_circle_outline_rounded;
}

/// Short label that fits on a turf card, e.g. "Car Parking" -> "Parking".
String amenityShortLabel(String amenity) {
  final lower = amenity.toLowerCase();
  if (lower.contains('park')) return 'Parking';
  if (lower.contains('wash')) return 'Washroom';
  if (lower.contains('room') || lower.contains('chang')) return 'Changing Room';
  if (lower.contains('water')) return 'Water';
  if (lower.contains('rent') || lower.contains('equip')) return 'Equipment';
  return amenity;
}
