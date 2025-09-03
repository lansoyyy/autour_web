import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show TextDirection;
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' hide TextDirection;
import 'package:autour_web/utils/const.dart' as c;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'dart:math';
import 'package:geolocator/geolocator.dart';

// Model for Emergency Alerts
class EmergencyAlert {
  final String id;
  final String title;
  final String message;
  final String priority;
  final double? latitude;
  final double? longitude;
  final String status;
  final String source;
  final DateTime timestamp;

  EmergencyAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.priority,
    this.latitude,
    this.longitude,
    required this.status,
    required this.source,
    required this.timestamp,
  });

  factory EmergencyAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyAlert(
      id: doc.id,
      title: data['title'] ?? 'Emergency Alert',
      message: data['message'] ?? '',
      priority: data['priority'] ?? 'medium',
      latitude: data['latitude'],
      longitude: data['longitude'],
      status: data['status'] ?? 'active',
      source: data['source'] ?? 'system',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'priority': priority,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'source': source,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

// Model for Weather Forecast
class WeatherForecast {
  final String day;
  final String date;
  final double tempHigh;
  final double tempLow;
  final String condition;
  final String icon;

  WeatherForecast({
    required this.day,
    required this.date,
    required this.tempHigh,
    required this.tempLow,
    required this.condition,
    required this.icon,
  });
}

// Model for Wave Conditions
class WaveCondition {
  final double height; // in meters
  final double period; // in seconds
  final String direction;
  final String quality; // poor, fair, good, excellent

  WaveCondition({
    required this.height,
    required this.period,
    required this.direction,
    required this.quality,
  });
}

// Model for Visitor Location
class VisitorLocation {
  final String visitorId;
  final String visitorName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String locationName;

  VisitorLocation({
    required this.visitorId,
    required this.visitorName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.locationName,
  });

  factory VisitorLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitorLocation(
      visitorId: data['visitorId'] ?? '',
      visitorName: data['visitorName'] ?? 'Unknown Visitor',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      locationName: data['locationName'] ?? 'Unknown Location',
    );
  }
}

// Model for Geofence Zone
class GeofenceZone {
  final String id;
  final String name;
  final String type; // 'safe' or 'danger'
  final List<latlng.LatLng> points;
  final String description;

  GeofenceZone({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    required this.description,
  });

  factory GeofenceZone.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<latlng.LatLng> polygonPoints = [];

    if (data['points'] != null && data['points'] is List) {
      for (var point in data['points']) {
        if (point is Map &&
            point.containsKey('latitude') &&
            point.containsKey('longitude')) {
          polygonPoints.add(latlng.LatLng(
              point['latitude'] as double, point['longitude'] as double));
        }
      }
    }

    return GeofenceZone(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Zone',
      type: data['type'] ?? 'danger',
      points: polygonPoints,
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'points': points
          .map((p) => {'latitude': p.latitude, 'longitude': p.longitude})
          .toList(),
      'description': description,
    };
  }
}

// Model for Health Center
class HealthCenter {
  final String id;
  final String name;
  final String address;
  final String contactNumber;
  final double latitude;
  final double longitude;
  final bool isHospital;
  final List<String> services;

  HealthCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.contactNumber,
    required this.latitude,
    required this.longitude,
    required this.isHospital,
    required this.services,
  });

  factory HealthCenter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthCenter(
      id: doc.id,
      name: data['name'] ?? 'Unknown Health Center',
      address: data['address'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      isHospital: data['isHospital'] ?? false,
      services: List<String>.from(data['services'] ?? []),
    );
  }
}

class DisasterPreparednessAdminScreen extends StatefulWidget {
  const DisasterPreparednessAdminScreen({super.key});

  @override
  State<DisasterPreparednessAdminScreen> createState() =>
      _DisasterPreparednessAdminScreenState();
}

class _DisasterPreparednessAdminScreenState
    extends State<DisasterPreparednessAdminScreen> {
  static const String _usersCollection = 'users';
  static const String _alertsCollection = 'emergency_alerts';
  static const String _geofencesCollection = 'geofence_zones';
  static const String _healthCentersCollection = 'health_centers';
  static const String _visitorLocationsCollection = 'visitor_locations';

  bool _isLoading = false;
  String? _errorMessage;
  bool _isCreatingGeofence = false;
  List<latlng.LatLng> _newGeofencePoints = [];
  String _newGeofenceType = 'danger'; // default to danger zone

  // Forecast data
  List<WeatherForecast> _forecastData = [];
  // Wave conditions for surfing
  WaveCondition _waveCondition = WaveCondition(
    height: 1.2,
    period: 8.5,
    direction: 'NE',
    quality: 'good',
  );

  // Emergency Alerts
  List<EmergencyAlert> _activeAlerts = [];

  // Geofence Zones
  List<GeofenceZone> _geofenceZones = [];

  // Health Centers
  List<HealthCenter> _healthCenters = [];

  // Visitor Tracking
  List<VisitorLocation> _visitorLocations = [];

  // Audio controller for emergency alerts
  html.AudioElement? _alertSound;

  // Map controllers
  MapController? _mapController;

  // Selected marker
  latlng.LatLng? _selectedLocation;

  // Current location
  latlng.LatLng _currentLocation = latlng.LatLng(c.auroraLat, c.auroraLon);

  // Location service status
  bool _locationServiceEnabled = false;
  bool _locationPermissionGranted = false;

  Map<String, String> weatherData = {
    'location': 'Baler, Aurora',
    'temperature': '--°C',
    'feels_like': '--°C',
    'condition': 'Loading...',
    'humidity': '--%',
    'wind_speed': '-- km/h',
    'visibility': '-- km',
    'uv_index': '--',
    'sunrise': '--:--',
    'sunset': '--:--',
    'precipitation': '--',
    'pressure': '-- hPa',
    'wave_height': '--m',
    'wave_period': '--s',
    'wave_direction': '--',
    'surf_quality': '--',
    'tide_level': '--m',
    'tide_timing': '--',
    'swell_direction': '--',
    'swell_size': '--m',
    'water_temperature': '--°C',
    'atmospheric_fronts': '--',
    'timestamp': '--', // Will be updated when weather data is fetched
  };

  List<Map<String, dynamic>> aiSuggestions = [
    {
      'title': 'Weather Advisory',
      'message':
          'Light rain expected in the afternoon. Carry an umbrella and avoid outdoor activities during heavy showers.',
      'icon': Icons.cloud,
      'color': Colors.blue,
      'priority': 'medium',
    },
    {
      'title': 'UV Protection',
      'message':
          'High UV index detected. Apply sunscreen with SPF 30+ and limit sun exposure between 10 AM - 4 PM.',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
      'priority': 'high',
    },
    {
      'title': 'Outdoor Activities',
      'message':
          'Weather is suitable for beach activities. However, be cautious of sudden weather changes.',
      'icon': Icons.beach_access,
      'color': Colors.green,
      'priority': 'low',
    },
    {
      'title': 'Health Reminder',
      'message':
          'High humidity may cause discomfort. Stay hydrated and avoid strenuous outdoor activities.',
      'icon': Icons.health_and_safety,
      'color': Colors.teal,
      'priority': 'medium',
    },
  ];

  void _refreshWeather() {
    // Get current location before refreshing weather
    _getCurrentLocation();
    _fetchForecast();
    _fetchWaveConditions();
    // Check for bad weather after refreshing
    _checkBadWeatherAndAlert();
  }

  // Play high-pitched alert sound
  void _playAlertSound() {
    try {
      _alertSound = html.AudioElement();
      _alertSound?.src = 'assets/sounds/alert.mp3';
      _alertSound?.play();
    } catch (e) {
      print('Error playing alert sound: $e');
    }
  }

  // Check if weather conditions are bad and play alert sound
  void _checkBadWeatherAndAlert() {
    try {
      // Get current weather condition
      final condition = weatherData['condition']?.toLowerCase() ?? '';

      // Define bad weather conditions
      final badWeatherConditions = [
        'thunderstorm',
        'rain',
        'heavy rain',
        'storm',
        'severe',
        'hurricane',
        'tornado',
        'blizzard',
        'extreme'
      ];

      // Check if any bad weather condition is present
      final isBadWeather = badWeatherConditions
          .any((badCondition) => condition.contains(badCondition));

      // Also check for high wind speeds
      final windSpeedStr = weatherData['wind_speed'] ?? '';
      final windSpeed = _extractNumberFromText(windSpeedStr);
      final isHighWind =
          windSpeed >= 50; // 50 km/h or more is considered high wind

      // Check for dangerous marine conditions
      final waveHeightStr = weatherData['wave_height'] ?? '';
      final waveHeight = _extractNumberFromText(waveHeightStr);
      final isDangerousWaves =
          waveHeight >= 3.0; // 3m or higher waves are dangerous

      // Check for extreme tide conditions
      final tideLevelStr = weatherData['tide_level'] ?? '';
      final tideLevel = _extractNumberFromText(tideLevelStr);
      final isExtremeTides =
          tideLevel >= 2.5; // 2.5m or higher tides are extreme

      // Play alert if bad weather is detected
      if (isBadWeather || isHighWind || isDangerousWaves || isExtremeTides) {
        _playAlertSound();

        // Show a snackbar notification as well
        if (mounted) {
          String alertMessage = '⚠️ Bad weather alert: $condition';
          if (isHighWind) alertMessage += ' (High winds)';
          if (isDangerousWaves) alertMessage += ' (Dangerous waves)';
          if (isExtremeTides) alertMessage += ' (Extreme tides)';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: TextWidget(
                text: alertMessage,
                fontSize: 14,
                color: white,
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking bad weather conditions: $e');
    }
  }

  // Helper method to extract number from text (e.g., "15 km/h" -> 15)
  double _extractNumberFromText(String text) {
    try {
      final regex = RegExp(r'(\d+\.?\d*)');
      final match = regex.firstMatch(text);
      if (match != null) {
        return double.tryParse(match.group(1) ?? '0') ?? 0;
      }
    } catch (e) {
      print('Error extracting number from text: $e');
    }
    return 0;
  }

  // Create a new emergency alert
  Future<void> _createEmergencyAlert(
      String title, String message, String priority,
      {double? latitude, double? longitude}) async {
    try {
      final alert = EmergencyAlert(
        id: '', // Firestore will generate this
        title: title,
        message: message,
        priority: priority,
        latitude: latitude,
        longitude: longitude,
        status: 'active',
        source: 'admin',
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection(_alertsCollection)
          .add(alert.toFirestore());

      // Play alert sound for high priority alerts
      if (priority == 'high') {
        _playAlertSound();
      }

      // If businesses need to be notified, handle that here
      if (priority == 'high') {
        _notifyNearbyBusinesses(title, message, latitude, longitude);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Emergency alert created',
            fontSize: 14,
            color: white,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Failed to create alert: $e',
            fontSize: 14,
            color: white,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Notify nearby businesses of emergency
  Future<void> _notifyNearbyBusinesses(
      String title, String message, double? latitude, double? longitude) async {
    try {
      // In a real implementation, this would query for businesses within a radius
      // and send notifications to them

      // For demo purposes, we'll just log it
      print('Notifying nearby businesses of emergency: $title');

      // Update UI to show notification was sent
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Nearby businesses have been notified',
            fontSize: 14,
            color: white,
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error notifying businesses: $e');
    }
  }

  // Create a new geofence zone
  Future<void> _createGeofenceZone(String name, String type,
      List<latlng.LatLng> points, String description) async {
    try {
      final zone = GeofenceZone(
        id: '', // Firestore will generate this
        name: name,
        type: type,
        points: points,
        description: description,
      );

      await FirebaseFirestore.instance
          .collection(_geofencesCollection)
          .add(zone.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Geofence zone created',
            fontSize: 14,
            color: white,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Reset geofence creation state
      setState(() {
        _isCreatingGeofence = false;
        _newGeofencePoints = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Failed to create geofence: $e',
            fontSize: 14,
            color: white,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Find nearest health center
  HealthCenter? _findNearestHealthCenter(double latitude, double longitude) {
    if (_healthCenters.isEmpty) return null;

    HealthCenter nearest = _healthCenters.first;
    double minDistance = _calculateDistance(
        latitude, longitude, nearest.latitude, nearest.longitude);

    for (var center in _healthCenters) {
      final distance = _calculateDistance(
          latitude, longitude, center.latitude, center.longitude);
      if (distance < minDistance) {
        minDistance = distance;
        nearest = center;
      }
    }

    return nearest;
  }

  // Calculate distance between two points (simple Haversine formula)
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Load data for health centers, geofences, and alerts
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load geofence zones
      final geofenceSnapshot = await FirebaseFirestore.instance
          .collection(_geofencesCollection)
          .get();

      final zones = geofenceSnapshot.docs
          .map((doc) => GeofenceZone.fromFirestore(doc))
          .toList();

      // Load health centers
      final healthCentersSnapshot = await FirebaseFirestore.instance
          .collection(_healthCentersCollection)
          .get();

      final centers = healthCentersSnapshot.docs
          .map((doc) => HealthCenter.fromFirestore(doc))
          .toList();

      // Load active alerts
      final alertsSnapshot = await FirebaseFirestore.instance
          .collection(_alertsCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('timestamp', descending: true)
          .get();

      final alerts = alertsSnapshot.docs
          .map((doc) => EmergencyAlert.fromFirestore(doc))
          .toList();

      setState(() {
        _geofenceZones = zones;
        _healthCenters = centers;
        _activeAlerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _errorMessage = 'Error loading data: $e';
        _isLoading = false;
      });
    }
  }

  // Fetch 5-day forecast
  Future<void> _fetchForecast() async {
    // In a real implementation, this would fetch from OpenWeatherMap's forecast API
    // For demo purposes, we'll use mock data

    final now = DateTime.now();
    final dayFormat = DateFormat('EEE');
    final dateFormat = DateFormat('d MMM');

    setState(() {
      _forecastData = List.generate(5, (index) {
        final day = now.add(Duration(days: index));
        return WeatherForecast(
          day: dayFormat.format(day),
          date: dateFormat.format(day),
          tempHigh: 28 + (index % 2), // Random variation
          tempLow: 24 + (index % 2),
          condition: index % 2 == 0 ? 'Partly Cloudy' : 'Light Rain',
          icon: index % 2 == 0 ? 'partly_cloudy' : 'rain',
        );
      });
    });
  }

  // Fetch wave conditions
  Future<void> _fetchWaveConditions() async {
    // In a real implementation, this would fetch from a surf forecasting API
    // For demo purposes, we'll use mock data

    setState(() {
      _waveCondition = WaveCondition(
        height: 1.2 + (DateTime.now().hour % 3) * 0.3, // Vary by time of day
        period: 8.5,
        direction: 'NE',
        quality: DateTime.now().hour > 6 && DateTime.now().hour < 10
            ? 'excellent'
            : 'good', // Better in the morning
      );

      // Update the weather data map
      try {
        weatherData['wave_height'] =
            '${_waveCondition.height.toStringAsFixed(1)}m';
        weatherData['wave_period'] =
            '${_waveCondition.period.toStringAsFixed(1)}s';
        weatherData['wave_direction'] = _waveCondition.direction;
        weatherData['surf_quality'] = _capitalize(_waveCondition.quality);
      } catch (e) {
        print('Error updating wave conditions in weather data: $e');
      }
    });
  }

  // --- Interactive Map Integration: Users on Map ---
  Widget _buildInteractiveUserMapCard() {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection(_usersCollection)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              print('Firestore error: ${snapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: 'Failed to load users',
                      fontSize: 14,
                      color: Colors.red,
                      fontFamily: 'Regular',
                    ),
                    TextWidget(
                      text: 'Error: ${snapshot.error}',
                      fontSize: 12,
                      color: Colors.red,
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            print('Total users found: ${docs.length}');

            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, color: grey, size: 48),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: 'No users found in database',
                      fontSize: 16,
                      color: grey,
                      fontFamily: 'Medium',
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: 'Users will appear here once they register',
                      fontSize: 12,
                      color: grey,
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              );
            }

            final markers = <Marker>[];
            int validLocationCount = 0;

            for (final d in docs) {
              final data = d.data();
              print(
                  'Processing user: ${data['fullName']} with data: ${data.keys.toList()}');

              final lat = (data['latitude'] as num?)?.toDouble();
              final lng = (data['longitude'] as num?)?.toDouble();

              print('User ${data['fullName']}: lat=$lat, lng=$lng');

              if (lat == null || lng == null) {
                print(
                    'Skipping user ${data['fullName']} - missing coordinates');
                continue;
              }

              validLocationCount++;

              final user = {
                'id': d.id,
                'fullName': data['fullName'],
                'dob': data['dob'],
                'nationality': data['nationality'],
                'email': data['email'],
                'mobile': data['mobile'],
                'emergencyContactName': data['emergencyContactName'],
                'emergencyContactNumber': data['emergencyContactNumber'],
                'medicalConditions': data['medicalConditions'],
                'address': data['address'],
                'latitude': lat,
                'longitude': lng,
                'preferences': data['preferences'],
                'sustainability': data['sustainability'],
                'role': data['role'],
                'createdAt': data['createdAt'],
                'updatedAt': data['updatedAt'],
              };

              markers.add(
                Marker(
                  width: 44,
                  height: 44,
                  point: latlng.LatLng(lat, lng),
                  child: GestureDetector(
                    onTap: () {
                      print('Marker tapped for user: ${user['fullName']}');
                      _showUserDetailsDialog(user);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              );
            }

            print('Valid users with coordinates: $validLocationCount');
            print('Total markers created: ${markers.length}');

            // Build map widget with error handling
            Widget mapWidget;
            try {
              mapWidget = FlutterMap(
                mapController:
                    _mapController, // This will be null if initialization failed, which is acceptable
                options: MapOptions(
                  initialCenter: latlng.LatLng(c.auroraLat, c.auroraLon),
                  initialZoom: 11,
                  minZoom: 5,
                  maxZoom: 18,
                  onMapReady: () {
                    print('Map is ready and loaded');
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'autour_web',
                    retinaMode: MediaQuery.of(context).devicePixelRatio > 1.5,
                    fallbackUrl:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    tileProvider: NetworkTileProvider(),
                  ),
                  MarkerLayer(markers: markers),
                ],
              );
            } catch (e) {
              print('Error rendering map: $e');
              mapWidget = Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: 'Failed to load map',
                      fontSize: 16,
                      color: Colors.red,
                      fontFamily: 'Medium',
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                mapWidget,
              ],
            );
          },
        ),
      ),
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: TextWidget(
            text: user['fullName']?.toString() ?? 'User Details',
            fontSize: 20,
            color: primary,
            fontFamily: 'Bold',
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Full name', user['fullName']),
                  _detailRow('Date of birth', user['dob']),
                  _detailRow('Nationality', user['nationality']),
                  _detailRow('Email', user['email']),
                  _detailRow('Mobile', user['mobile']),
                  _detailRow('Emergency contact', user['emergencyContactName']),
                  _detailRow(
                      'Emergency number', user['emergencyContactNumber']),
                  _detailRow('Medical conditions', user['medicalConditions']),
                  _detailRow('Address', user['address']),
                  _detailRow('Latitude', user['latitude']?.toString()),
                  _detailRow('Longitude', user['longitude']?.toString()),
                  _detailRow('Role', user['role']),
                  _detailRow('Preferences', _formatList(user['preferences'])),
                  _detailRow(
                      'Sustainability', _formatList(user['sustainability'])),
                  _detailRow('Created at', _formatTimestamp(user['createdAt'])),
                  _detailRow('Updated at', _formatTimestamp(user['updatedAt'])),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: TextWidget(
                text: 'Close',
                fontSize: 14,
                color: grey,
                fontFamily: 'Regular',
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatList(dynamic value) {
    if (value == null) return '—';
    if (value is List) return value.join(', ');
    return value.toString();
  }

  String _formatTimestamp(dynamic value) {
    try {
      if (value == null) return '—';
      if (value is Timestamp) {
        final dt = value.toDate();
        return DateFormat('y-MM-dd HH:mm').format(dt);
      }
      return value.toString();
    } catch (_) {
      return value.toString();
    }
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: TextWidget(
              text: label,
              fontSize: 13,
              color: grey,
              fontFamily: 'Regular',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextWidget(
              text: (value == null || value.toString().isEmpty)
                  ? '—'
                  : value.toString(),
              fontSize: 14,
              color: black,
              fontFamily: 'Medium',
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Initialize map controller
    try {
      _mapController = MapController();
    } catch (e) {
      print('Error initializing map controller: $e');
      _mapController = null; // Set to null if initialization fails
    }

    _fetchWeather();
    _fetchForecast();
    _fetchWaveConditions();
    _loadData();

    // The weather timestamp is already initialized in the weatherData declaration
    // We'll just wrap any access to it in try-catch blocks

    // Initialize alert sound
    _alertSound = html.AudioElement();
    _alertSound?.src = 'assets/sounds/alert.mp3';

    // Initialize location services
    _initializeLocationServices();

    // Add sample health centers if we don't have any
    _addSampleData();

    // Set up periodic refresh
    Timer.periodic(const Duration(minutes: 15), (timer) {
      _refreshWeather();
    });

    // Listen for real-time updates on alerts
    FirebaseFirestore.instance
        .collection(_alertsCollection)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      final alerts = snapshot.docs
          .map((doc) => EmergencyAlert.fromFirestore(doc))
          .toList();

      if (mounted) {
        setState(() {
          _activeAlerts = alerts;
        });
      }

      // Check for any new high-priority alerts
      final highPriorityAlerts = alerts
          .where((a) =>
              a.priority == 'high' &&
              a.timestamp
                  .isAfter(DateTime.now().subtract(const Duration(minutes: 5))))
          .toList();

      if (highPriorityAlerts.isNotEmpty) {
        _playAlertSound();
      }
    });

    // Listen for visitor location updates
    FirebaseFirestore.instance
        .collection(_visitorLocationsCollection)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
      final locations = snapshot.docs
          .map((doc) => VisitorLocation.fromFirestore(doc))
          .toList();

      if (mounted) {
        setState(() {
          _visitorLocations = locations;
        });
      }
    });
  }

  // Add sample data for demo purposes
  Future<void> _addSampleData() async {
    // Sample health centers
    final healthCentersCollection =
        FirebaseFirestore.instance.collection(_healthCentersCollection);
    final healthCentersSnapshot = await healthCentersCollection.get();

    if (healthCentersSnapshot.docs.isEmpty) {
      // Add sample health centers
      await healthCentersCollection.add({
        'name': 'Aurora Provincial Hospital',
        'address': 'Quezon St, Baler, Aurora',
        'contactNumber': '(+63) 949-123-4567',
        'latitude': 15.7600,
        'longitude': 121.5560,
        'isHospital': true,
        'services': [
          'Emergency Room',
          'General Medicine',
          'Surgery',
          'Pediatrics',
          'Obstetrics',
          'Laboratory',
          'Radiology',
        ],
      });

      await healthCentersCollection.add({
        'name': 'Baler Rural Health Unit',
        'address': 'Rizal St, Baler, Aurora',
        'contactNumber': '(+63) 918-765-4321',
        'latitude': 15.7622,
        'longitude': 121.5643,
        'isHospital': false,
        'services': [
          'General Consultation',
          'Immunization',
          'First Aid',
          'Maternal Care',
          'Child Health Services',
        ],
      });

      await healthCentersCollection.add({
        'name': 'Sabang Health Center',
        'address': 'Sabang Beach, Baler, Aurora',
        'contactNumber': '(+63) 927-888-9999',
        'latitude': 15.7540,
        'longitude': 121.5720,
        'isHospital': false,
        'services': [
          'First Aid',
          'Emergency Treatment',
          'Basic Medical Care',
        ],
      });
    }

    // Sample geofence zones
    final geofencesCollection =
        FirebaseFirestore.instance.collection(_geofencesCollection);
    final geofencesSnapshot = await geofencesCollection.get();

    if (geofencesSnapshot.docs.isEmpty) {
      // Add sample safe zone (swimming area)
      await geofencesCollection.add({
        'name': 'Sabang Beach Safe Swimming Zone',
        'type': 'safe',
        'description':
            'Designated safe swimming area with lifeguard supervision',
        'points': [
          {'latitude': 15.7533, 'longitude': 121.5713},
          {'latitude': 15.7536, 'longitude': 121.5727},
          {'latitude': 15.7528, 'longitude': 121.5732},
          {'latitude': 15.7525, 'longitude': 121.5717},
        ],
      });

      // Add sample danger zone (rip current area)
      await geofencesCollection.add({
        'name': 'Strong Current Danger Zone',
        'type': 'danger',
        'description':
            'Area with dangerous rip currents - swimming not advised',
        'points': [
          {'latitude': 15.7545, 'longitude': 121.5740},
          {'latitude': 15.7552, 'longitude': 121.5755},
          {'latitude': 15.7542, 'longitude': 121.5760},
          {'latitude': 15.7537, 'longitude': 121.5748},
        ],
      });
    }

    // Sample visitor locations
    final visitorsCollection =
        FirebaseFirestore.instance.collection(_visitorLocationsCollection);
    final visitorsSnapshot = await visitorsCollection.get();

    if (visitorsSnapshot.docs.isEmpty) {
      // Add sample visitor locations
      final now = DateTime.now();
      final random = Random();

      for (int i = 0; i < 5; i++) {
        // Random location near Baler
        final lat = 15.755 + (random.nextDouble() - 0.5) * 0.02;
        final lng = 121.565 + (random.nextDouble() - 0.5) * 0.02;

        await visitorsCollection.add({
          'visitorId': 'visitor-${i + 1}',
          'visitorName': 'Tourist ${i + 1}',
          'latitude': lat,
          'longitude': lng,
          'timestamp':
              Timestamp.fromDate(now.subtract(Duration(minutes: i * 30))),
          'locationName': i % 2 == 0 ? 'Sabang Beach' : 'Downtown Baler',
        });
      }
    }
  }

  // Initialize location services
  Future<void> _initializeLocationServices() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      setState(() {
        _locationServiceEnabled = serviceEnabled;
      });

      if (!serviceEnabled) {
        // Location services are not enabled, use default location
        _useDefaultLocation();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions denied, use default location
          _useDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions permanently denied, use default location
        _useDefaultLocation();
        return;
      }

      // Permissions granted
      setState(() {
        _locationPermissionGranted = true;
      });

      // Get current position
      _getCurrentLocation();
    } catch (e) {
      print('Error initializing location services: $e');
      _useDefaultLocation();
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = latlng.LatLng(position.latitude, position.longitude);
      });

      // Update location in weather data
      _updateLocationInWeatherData();

      // Fetch weather for new location
      _fetchWeather();
    } catch (e) {
      print('Error getting current location: $e');
      _useDefaultLocation();
    }
  }

  // Use default location
  void _useDefaultLocation() {
    setState(() {
      _currentLocation = latlng.LatLng(c.auroraLat, c.auroraLon);
      weatherData['location'] = c.auroraLocationLabel;
    });
    _fetchWeather();
  }

  // Update location in weather data
  void _updateLocationInWeatherData() {
    // In a real implementation, you would reverse geocode the coordinates to get the location name
    // For now, we'll just use the coordinates
    setState(() {
      weatherData['location'] =
          '${_currentLocation.latitude.toStringAsFixed(4)}, ${_currentLocation.longitude.toStringAsFixed(4)}';
    });
  }

  @override
  void dispose() {
    // Dispose map controller safely
    try {
      _mapController?.dispose();
    } catch (e) {
      print('Error disposing map controller: $e');
    }

    // Clean up audio resources
    _alertSound?.pause();
    _alertSound = null;
    super.dispose();
  }

  Future<void> _fetchWeather() async {
    if (c.weatherApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Missing OpenWeather API key. Set OPENWEATHER_API_KEY.',
            fontSize: 14,
            color: white,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final uri = Uri.parse(
        '${c.weatherApiEndpoint}?lat=${_currentLocation.latitude}&lon=${_currentLocation.longitude}&appid=${c.weatherApiKey}&units=metric');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body) as Map<String, dynamic>;

          // Extract weather data with null safety
          final weatherDescription =
              (data['weather']?[0]?['description'] ?? '').toString();
          final double temp = (data['main']?['temp'] ?? 0).toDouble();
          final double feelsLike =
              (data['main']?['feels_like'] ?? 0).toDouble();
          final int pressure = (data['main']?['pressure'] ?? 0).toInt();
          final int humidity = (data['main']?['humidity'] ?? 0).toInt();
          final double windMs = (data['wind']?['speed'] ?? 0).toDouble();
          final double windKmh = windMs * 3.6;
          final int visibilityM = (data['visibility'] ?? 0).toInt();
          final double visibilityKm =
              visibilityM > 0 ? visibilityM / 1000.0 : 0;
          final int sunrise = (data['sys']?['sunrise'] ?? 0).toInt();
          final int sunset = (data['sys']?['sunset'] ?? 0).toInt();

          // Precipitation last 1h if present
          String precipitation = '—';
          try {
            if (data['rain'] != null &&
                data['rain'] is Map &&
                data['rain']['1h'] != null) {
              precipitation =
                  '${(data['rain']['1h'] as num).toString()} mm (1h)';
            }
          } catch (e) {
            print('Error processing precipitation data: $e');
          }

          // Format timestamps safely
          final timeFmt = DateFormat('h:mm a');
          String fmtUnix(int ts) {
            try {
              if (ts <= 0) return '—';
              return timeFmt.format(
                  DateTime.fromMillisecondsSinceEpoch(ts * 1000).toLocal());
            } catch (e) {
              print('Error formatting timestamp: $e');
              return '—';
            }
          }

          // Update UI data
          try {
            // Create a new map with all data safely initialized
            final Map<String, String> updatedWeatherData = {
              'location': weatherData['location'] ?? c.auroraLocationLabel,
              'temperature': '${temp.toStringAsFixed(1)}°C',
              'feels_like': '${feelsLike.toStringAsFixed(1)}°C',
              'condition': _capitalize(weatherDescription),
              'humidity': '$humidity%',
              'wind_speed': '${windKmh.toStringAsFixed(0)} km/h',
              'visibility': visibilityKm > 0
                  ? '${visibilityKm.toStringAsFixed(1)} km'
                  : '—',
              'uv_index': _fetchUVIndex(
                  _currentLocation.latitude, _currentLocation.longitude),
              'sunrise': fmtUnix(sunrise),
              'sunset': fmtUnix(sunset),
              'precipitation': precipitation,
              'pressure': '$pressure hPa',
              'wave_height': _fetchWaveData(_currentLocation.latitude,
                  _currentLocation.longitude, 'height'),
              'wave_period': _fetchWaveData(_currentLocation.latitude,
                  _currentLocation.longitude, 'period'),
              'wave_direction': _fetchWaveData(_currentLocation.latitude,
                  _currentLocation.longitude, 'direction'),
              'tide_level': _fetchTideData(_currentLocation.latitude,
                  _currentLocation.longitude, 'level'),
              'tide_timing': _fetchTideData(_currentLocation.latitude,
                  _currentLocation.longitude, 'timing'),
              'swell_direction': _fetchSwellData(_currentLocation.latitude,
                  _currentLocation.longitude, 'direction'),
              'swell_size': _fetchSwellData(_currentLocation.latitude,
                  _currentLocation.longitude, 'size'),
              'water_temperature': _fetchWaterTemperature(
                  _currentLocation.latitude, _currentLocation.longitude),
              'atmospheric_fronts': _fetchAtmosphericFronts(
                  _currentLocation.latitude, _currentLocation.longitude),
              'timestamp': DateFormat('EEEE h:mm a').format(DateTime.now()),
            };

            setState(() {
              weatherData = updatedWeatherData;
            });

            // Check for bad weather conditions after updating weather data
            _checkBadWeatherAndAlert();
          } catch (e) {
            print('Error updating weather data: $e');
            setState(() {
              _errorMessage = 'Error updating weather data: $e';
            });
          }

          // Persist weather to Firestore for mobile coordination
          try {
            final Map<String, dynamic> payload = {
              'region': weatherData['location'] ?? c.auroraLocationLabel,
              'lat': _currentLocation.latitude,
              'lon': _currentLocation.longitude,
              'temperature_c': temp,
              'feels_like_c': feelsLike,
              'condition': weatherDescription,
              'humidity': humidity,
              'wind_kmh': windKmh,
              'visibility_km': visibilityKm,
              'sunrise_unix': sunrise,
              'sunset_unix': sunset,
              'pressure_hpa': pressure,
              'updatedAt': FieldValue.serverTimestamp(),
            };

            // Safely add precipitation data if available
            if (data['rain'] != null &&
                data['rain'] is Map &&
                data['rain']['1h'] != null) {
              payload['precipitation_mm_1h'] = data['rain']['1h'];
            }

            // Snapshot history
            await FirebaseFirestore.instance
                .collection('weather_snapshots')
                .add(payload);

            // Current weather document per region
            final regionDoc =
                _regionDocId(weatherData['location'] ?? c.auroraLocationLabel);
            await FirebaseFirestore.instance
                .collection('current_weather')
                .doc(regionDoc)
                .set(payload, SetOptions(merge: true));
          } catch (e) {
            // Log persistence errors but keep UI responsive
            print('Error persisting weather data: $e');
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: TextWidget(
                text: 'Weather data updated',
                fontSize: 14,
                color: white,
              ),
              backgroundColor: primary,
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          // Error parsing JSON or processing weather data
          print('Error processing weather data: $e');
          setState(() {
            _errorMessage = 'Error processing weather data: $e';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: TextWidget(
                text: 'Error processing weather data',
                fontSize: 14,
                color: white,
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Request failed: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: TextWidget(
              text: _errorMessage!,
              fontSize: 14,
              color: white,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'An error occurred',
            fontSize: 14,
            color: white,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // Fetch UV index (mock implementation)
  String _fetchUVIndex(double lat, double lon) {
    // In a real implementation, you would call a UV index API
    // For now, we'll return a mock value based on location/time
    final hour = DateTime.now().hour;
    if (hour >= 10 && hour <= 16) {
      return 'High';
    } else if (hour >= 8 && hour <= 18) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }

  // Fetch wave data (mock implementation)
  String _fetchWaveData(double lat, double lon, String type) {
    // In a real implementation, you would call a wave data API
    // For now, we'll return mock values
    switch (type) {
      case 'height':
        return '${1.0 + Random().nextDouble() * 2.0}'.substring(0, 3) + 'm';
      case 'period':
        return '${7 + Random().nextInt(5)}s';
      case 'direction':
        final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
        return directions[Random().nextInt(directions.length)];
      default:
        return '—';
    }
  }

  // Fetch tide data (mock implementation)
  String _fetchTideData(double lat, double lon, String type) {
    // In a real implementation, you would call a tide data API
    // For now, we'll return mock values
    switch (type) {
      case 'level':
        return '${0.5 + Random().nextDouble() * 2.0}'.substring(0, 3) + 'm';
      case 'timing':
        final now = DateTime.now();
        final nextHighTide = now.add(Duration(hours: 6 + Random().nextInt(6)));
        return 'High tide at ${DateFormat('HH:mm').format(nextHighTide)}';
      default:
        return '—';
    }
  }

  // Fetch swell data (mock implementation)
  String _fetchSwellData(double lat, double lon, String type) {
    // In a real implementation, you would call a swell data API
    // For now, we'll return mock values
    switch (type) {
      case 'direction':
        final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
        return directions[Random().nextInt(directions.length)];
      case 'size':
        return '${0.5 + Random().nextDouble() * 1.5}'.substring(0, 3) + 'm';
      default:
        return '—';
    }
  }

  // Fetch water temperature (mock implementation)
  String _fetchWaterTemperature(double lat, double lon) {
    // In a real implementation, you would call a water temperature API
    // For now, we'll return a mock value based on location/time
    final baseTemp = 26.0; // Base temperature for tropical waters
    final variation = Random().nextDouble() * 2.0 - 1.0; // -1 to +1 variation
    return '${(baseTemp + variation).toStringAsFixed(1)}°C';
  }

  // Fetch atmospheric fronts (mock implementation)
  String _fetchAtmosphericFronts(double lat, double lon) {
    // In a real implementation, you would call an atmospheric data API
    // For now, we'll return mock values
    final fronts = ['Stable', 'Approaching Cold Front', 'High Pressure System'];
    return fronts[Random().nextInt(fronts.length)];
  }

  // Generate document ID for region
  String _regionDocId(String region) {
    return region
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  // Build weather chart
  Widget _buildWeatherChart() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: CustomPaint(
        painter: _TemperatureChartPainter(),
        size: const Size(double.infinity, 120),
      ),
    );
  }

  // Build marine conditions card
  Widget _buildMarineConditionsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: 'Marine Conditions',
              fontSize: 18,
              color: primary,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMarineMetricCard(
                  'Wave Height',
                  weatherData['wave_height'] ?? '—',
                  Icons.waves,
                ),
                const SizedBox(width: 16),
                _buildMarineMetricCard(
                  'Wave Period',
                  weatherData['wave_period'] ?? '—',
                  Icons.access_time,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMarineMetricCard(
                  'Tide Level',
                  weatherData['tide_level'] ?? '—',
                  Icons.water,
                ),
                const SizedBox(width: 16),
                _buildMarineMetricCard(
                  'Water Temp',
                  weatherData['water_temperature'] ?? '—',
                  Icons.thermostat,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build marine metric card
  Widget _buildMarineMetricCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary, size: 24),
            const SizedBox(height: 4),
            TextWidget(
              text: title,
              fontSize: 12,
              color: grey,
              fontFamily: 'Regular',
            ),
            TextWidget(
              text: value,
              fontSize: 14,
              color: black,
              fontFamily: 'Bold',
            ),
          ],
        ),
      ),
    );
  }

  // Build atmospheric conditions card
  Widget _buildAtmosphericConditionsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: 'Atmospheric Conditions',
              fontSize: 18,
              color: primary,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAtmosphericMetricCard(
                  'Pressure',
                  weatherData['pressure'] ?? '—',
                  Icons.speed,
                ),
                const SizedBox(width: 16),
                _buildAtmosphericMetricCard(
                  'UV Index',
                  weatherData['uv_index'] ?? '—',
                  Icons.wb_sunny,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildAtmosphericMetricCard(
                  'Fronts',
                  weatherData['atmospheric_fronts'] ?? '—',
                  Icons.air,
                ),
                const SizedBox(width: 16),
                _buildAtmosphericMetricCard(
                  'Visibility',
                  weatherData['visibility'] ?? '—',
                  Icons.visibility,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build atmospheric metric card
  Widget _buildAtmosphericMetricCard(
      String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: primary.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary, size: 24),
            const SizedBox(height: 4),
            TextWidget(
              text: title,
              fontSize: 12,
              color: grey,
              fontFamily: 'Regular',
            ),
            TextWidget(
              text: value,
              fontSize: 14,
              color: black,
              fontFamily: 'Bold',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              TextWidget(
                text: 'Disaster Preparedness Dashboard',
                fontSize: 28,
                color: primary,
                fontFamily: 'Bold',
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: 'Monitor weather conditions and emergency alerts',
                fontSize: 16,
                color: grey,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 32),

              // Weather Overview Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Current Weather',
                            fontSize: 20,
                            color: primary,
                            fontFamily: 'Bold',
                          ),
                          ButtonWidget(
                            label: 'Refresh',
                            onPressed: _refreshWeather,
                            color: primary,
                            textColor: white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Weather Icon and Main Info
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.wb_sunny,
                                color: primary,
                                size: 48,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Weather Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text:
                                      'Current Location: ${weatherData['location']}',
                                  fontSize: 16,
                                  color: black,
                                  fontFamily: 'Medium',
                                ),
                                const SizedBox(height: 8),
                                TextWidget(
                                  text: weatherData['condition'] ?? 'Unknown',
                                  fontSize: 24,
                                  color: black,
                                  fontFamily: 'Bold',
                                ),
                                const SizedBox(height: 8),
                                TextWidget(
                                  text:
                                      '${weatherData['temperature'] ?? '0°C'} • Feels like ${weatherData['feels_like'] ?? '0°C'}',
                                  fontSize: 18,
                                  color: grey,
                                  fontFamily: 'Regular',
                                ),
                                const SizedBox(height: 8),
                                TextWidget(
                                  text: weatherData['timestamp'] ??
                                      'Last updated: —',
                                  fontSize: 12,
                                  color: grey,
                                  fontFamily: 'Regular',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Weather Details Grid
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _buildWeatherDetail(
                                      'Precipitation',
                                      weatherData['precipitation'] ?? '—',
                                      Icons.water_drop),
                                  _buildWeatherDetail(
                                      'Humidity',
                                      weatherData['humidity'] ?? '—',
                                      Icons.water),
                                  _buildWeatherDetail(
                                      'Wind',
                                      weatherData['wind_speed'] ?? '—',
                                      Icons.air),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _buildWeatherDetail(
                                      'Sunrise',
                                      weatherData['sunrise'] ?? '—',
                                      Icons.wb_sunny),
                                  _buildWeatherDetail(
                                      'Sunset',
                                      weatherData['sunset'] ?? '—',
                                      Icons.nights_stay),
                                  _buildWeatherDetail(
                                      'Pressure',
                                      weatherData['pressure'] ?? '—',
                                      Icons.speed),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Weather Chart
              _buildWeatherChart(),
              const SizedBox(height: 32),

              // Marine Conditions
              _buildMarineConditionsCard(),
              const SizedBox(height: 32),

              // Atmospheric Conditions
              _buildAtmosphericConditionsCard(),
              const SizedBox(height: 32),

              // 5-Day Forecast
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: '5-Day Forecast',
                        fontSize: 20,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _forecastData.length,
                          itemBuilder: (context, index) {
                            final forecast = _forecastData[index];
                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextWidget(
                                    text: forecast.day,
                                    fontSize: 14,
                                    color: black,
                                    fontFamily: 'Bold',
                                  ),
                                  TextWidget(
                                    text: forecast.date,
                                    fontSize: 12,
                                    color: grey,
                                    fontFamily: 'Regular',
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(
                                    forecast.condition.contains('Rain')
                                        ? Icons.cloud
                                        : Icons.wb_sunny,
                                    color: primary,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  TextWidget(
                                    text: '${forecast.tempHigh}°',
                                    fontSize: 16,
                                    color: black,
                                    fontFamily: 'Bold',
                                  ),
                                  TextWidget(
                                    text: '${forecast.tempLow}°',
                                    fontSize: 14,
                                    color: grey,
                                    fontFamily: 'Regular',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Interactive Map
              TextWidget(
                text: 'User Locations',
                fontSize: 20,
                color: primary,
                fontFamily: 'Bold',
              ),
              const SizedBox(height: 16),
              _buildInteractiveUserMapCard(),
              const SizedBox(height: 32),

              // Emergency Alerts
              TextWidget(
                text: 'Emergency Alerts',
                fontSize: 20,
                color: primary,
                fontFamily: 'Bold',
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primary.withOpacity(0.2)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _activeAlerts.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.notifications_none,
                                color: grey,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              TextWidget(
                                text: 'No active emergency alerts',
                                fontSize: 16,
                                color: grey,
                                fontFamily: 'Regular',
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: _activeAlerts.map((alert) {
                            Color alertColor = Colors.blue;
                            if (alert.priority == 'high') {
                              alertColor = Colors.red;
                            } else if (alert.priority == 'medium') {
                              alertColor = Colors.orange;
                            }

                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: alertColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: alertColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber,
                                        color: alertColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextWidget(
                                          text: alert.title,
                                          fontSize: 18,
                                          color: alertColor,
                                          fontFamily: 'Bold',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextWidget(
                                    text: alert.message,
                                    fontSize: 14,
                                    color: black,
                                    fontFamily: 'Regular',
                                  ),
                                  const SizedBox(height: 8),
                                  TextWidget(
                                    text:
                                        '${DateFormat('MMM dd, yyyy HH:mm').format(alert.timestamp)} • ${alert.source}',
                                    fontSize: 12,
                                    color: grey,
                                    fontFamily: 'Regular',
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build weather detail widget
  Widget _buildWeatherDetail(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: primary, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: label,
                fontSize: 12,
                color: grey,
                fontFamily: 'Regular',
              ),
              TextWidget(
                text: value,
                fontSize: 14,
                color: black,
                fontFamily: 'Bold',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for the temperature chart
class _TemperatureChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint fillPaint = Paint()
      ..color = Colors.amber.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Sample temperature data points
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.125, size.height * 0.75),
      Offset(size.width * 0.25, size.height * 0.75),
      Offset(size.width * 0.375, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.625, size.height * 0.3),
      Offset(size.width * 0.75, size.height * 0.5),
      Offset(size.width * 0.875, size.height * 0.6),
      Offset(size.width, size.height * 0.7),
    ];

    // Create path for the line
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw the line
    canvas.drawPath(path, linePaint);

    // Create filled area below the line
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Draw the filled area
    canvas.drawPath(fillPath, fillPaint);

    // Draw temperature markers
    final markerPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    // Draw temperature markers and values
    final temps = ['26', '25', '25', '25', '27', '28', '27', '26'];
    for (int i = 0; i < points.length - 1 && i < temps.length; i++) {
      // Draw marker
      canvas.drawCircle(points[i], 4, markerPaint);

      // Draw temperature value
      final textSpan = TextSpan(
        text: temps[i],
        style: textStyle,
      );
      try {
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas,
            Offset(points[i].dx - textPainter.width / 2, points[i].dy - 20));
      } catch (e) {
        print('Error painting text: $e');
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
