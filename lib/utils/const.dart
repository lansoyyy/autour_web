// import 'package:firebase_auth/firebase_auth.dart';

// String userId = FirebaseAuth.instance.currentUser!.uid;

String logo = 'assets/images/logo.png';
String label = 'assets/images/label.png';
String avatar = 'assets/images/avatar.png';
String icon = 'assets/images/icon.png';

List socials = [
  'assets/images/phone.png',
  'assets/images/apple.png',
  'assets/images/google.png',
  'assets/images/facebook.png'
];

List foodCategories = [
  'assets/images/fastfood.png',
  'assets/images/coffee.png',
  'assets/images/donut.png',
  'assets/images/bbq.png',
  'assets/images/pizza.png'
];
List foodCategoriesName = [
  'Fastfood',
  'Drinks',
  'Donut',
  'BBQ',
  'Pizza',
];

List shopCategories = [
  'Combo',
  'Meals',
  'Snacks',
  'Drinks',
  'Add-ons',
];

String home = 'assets/images/home.png';
String office = 'assets/images/office.png';
String groups = 'assets/images/groups.png';
String gcash = 'assets/images/image 5.png';
String paymaya = 'assets/images/image 6.png';
String bpi = 'assets/images/clarity_bank-solid.png';

// Weather API configuration (OpenWeatherMap)
const String weatherApiEndpoint =
    'https://api.openweathermap.org/data/2.5/weather';
// TODO: Provide your API key, or pass via --dart-define=OPENWEATHER_API_KEY=YOUR_KEY when building.
const String weatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY',
    defaultValue: '67a96ca939095cc12748c226c7d3851c');
// Default coordinates for Aurora Province (Baler, Aurora, PH)
const double auroraLat = 15.7589;
const double auroraLon = 121.5623;
const String auroraLocationLabel = 'Baler, Aurora';
