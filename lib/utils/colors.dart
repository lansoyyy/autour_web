import 'package:flutter/material.dart';

const primary =
    Color(0xFF2A6F97); // Ocean Blue: Evokes coastal vibes of Aurora Province
const secondary =
    Color(0xFFF4A261); // Warm Sandstone: Represents sandy beaches or sunsets
const darkPrimary = Color(
    0xFF1A3C5A); // Midnight Sea: A deeper blue for contrast in dark themes
const black =
    Color(0xFF121212); // Deep Charcoal: A softer black for backgrounds
const white = Color(0xFFF5F6F5); // Soft Cloud: A warm off-white for clean UI
const grey = Color(0xFF8A8A8A); // Stone Grey: Neutral tone for text or borders
TimeOfDay parseTime(String timeString) {
  List<String> parts = timeString.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}
