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
  late final MapController _mapController;

  // Selected marker
  latlng.LatLng? _selectedLocation;

  // Current location
  latlng.LatLng _currentLocation = latlng.LatLng(c.auroraLat, c.auroraLon);

  Map<String, String> weatherData = {
    'location': 'Baler, Aurora',
    'temperature': '28°C',
    'feels_like': '32°C',
    'condition': 'Partly Cloudy',
    'humidity': '75%',
    'wind_speed': '15 km/h',
    'visibility': '10 km',
    'uv_index': 'High',
    'sunrise': '5:45 AM',
    'sunset': '6:15 PM',
    'precipitation': '20%',
    'pressure': '1013 hPa',
    'wave_height': '1.2m',
    'wave_period': '8.5s',
    'wave_direction': 'NE',
    'surf_quality': 'Good',
    'timestamp': DateFormat('EEEE h:mm a').format(DateTime.now()),
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
    _fetchWeather();
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

      // Play alert if bad weather is detected
      if (isBadWeather || isHighWind) {
        _playAlertSound();

        // Show a snackbar notification as well
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: TextWidget(
                text: '⚠️ Bad weather alert: $condition',
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
                mapController: _mapController,
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
    }

    // _fetchWeather();
    _fetchForecast();
    _fetchWaveConditions();
    _loadData();

    // The weather timestamp is already initialized in the weatherData declaration
    // We'll just wrap any access to it in try-catch blocks

    // Initialize alert sound
    _alertSound = html.AudioElement();
    _alertSound?.src = 'assets/sounds/alert.mp3';

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

  @override
  void dispose() {
    // Dispose map controller safely
    try {
      _mapController.dispose();
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
        '${c.weatherApiEndpoint}?lat=${c.auroraLat}&lon=${c.auroraLon}&appid=${c.weatherApiKey}&units=metric');

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
              'location': c.auroraLocationLabel,
              'temperature': '${temp.toStringAsFixed(1)}°C',
              'feels_like': '${feelsLike.toStringAsFixed(1)}°C',
              'condition': _capitalize(weatherDescription),
              'humidity': '$humidity%',
              'wind_speed': '${windKmh.toStringAsFixed(0)} km/h',
              'visibility': visibilityKm > 0
                  ? '${visibilityKm.toStringAsFixed(1)} km'
                  : '—',
              'uv_index': '—',
              'sunrise': fmtUnix(sunrise),
              'sunset': fmtUnix(sunset),
              'precipitation': precipitation,
              'pressure': '$pressure hPa',
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
              'region': c.auroraLocationLabel,
              'lat': c.auroraLat,
              'lon': c.auroraLon,
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
            final regionDoc = _regionDocId(c.auroraLocationLabel);
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

  // --- Helpers for Firestore-backed AI suggestions and region ---
  String _regionDocId(String label) => label.replaceAll(' ', '_').toLowerCase();

  IconData _resolveIcon(String name) {
    switch (name) {
      case 'cloud':
        return Icons.cloud;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'beach_access':
        return Icons.beach_access;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'warning':
        return Icons.warning;
      case 'tips':
        return Icons.tips_and_updates;
      default:
        return Icons.info_outline;
    }
  }

  Color _resolveColor(String name) {
    switch (name) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'teal':
        return Colors.teal;
      case 'blue':
        return Colors.blue;
      default:
        return primary;
    }
  }

  String _colorNameForPriority(String p) {
    switch (p) {
      case 'high':
        return 'red';
      case 'medium':
        return 'orange';
      default:
        return 'green';
    }
  }

  String _iconNameForPriority(String p) {
    switch (p) {
      case 'high':
        return 'warning';
      case 'medium':
        return 'cloud';
      default:
        return 'beach_access';
    }
  }

  void _showEditAISuggestionDialog(
      {Map<String, dynamic>? suggestion, String? docId}) {
    final titleController =
        TextEditingController(text: suggestion?['title'] ?? '');
    final messageController =
        TextEditingController(text: suggestion?['message'] ?? '');
    String priority = suggestion?['priority'] ?? 'medium';
    // icon/color derived from priority on save
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: suggestion == null ? 'Add AI Suggestion' : 'Edit AI Suggestion',
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                  maxLines: 2,
                ),
                DropdownButtonFormField<String>(
                  value: priority,
                  items: [
                    DropdownMenuItem(value: 'high', child: Text('High')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => priority = val);
                  },
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                // For demo, icon and color are not editable
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: grey,
              fontFamily: 'Regular',
            ),
          ),
          ButtonWidget(
            label: suggestion == null ? 'Add' : 'Update',
            onPressed: () async {
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              final iconName = _iconNameForPriority(priority);
              final colorName = _colorNameForPriority(priority);
              final payload = {
                'title': titleController.text,
                'message': messageController.text,
                'priority': priority,
                'icon': iconName,
                'color': colorName,
                'region': c.auroraLocationLabel,
                'updatedAt': FieldValue.serverTimestamp(),
              };
              try {
                final col =
                    FirebaseFirestore.instance.collection('ai_suggestions');
                if (docId == null) {
                  await col.add({
                    ...payload,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                } else {
                  await col.doc(docId).set(payload, SetOptions(merge: true));
                }
              } catch (_) {
                // surface minimal error to user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: TextWidget(
                      text: 'Failed to save suggestion',
                      fontSize: 14,
                      color: white,
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            color: primary,
            textColor: white,
            width: 100,
            height: 45,
            fontSize: 16,
            radius: 10,
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAISuggestion(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('ai_suggestions')
          .doc(docId)
          .delete();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: TextWidget(
            text: 'Failed to delete suggestion',
            fontSize: 14,
            color: white,
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Show dialog to save geofence
  void _showGeofenceSaveDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String type = _newGeofenceType;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Save Geofence Zone',
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Zone Name',
                hintText: 'e.g., Beach Safe Zone',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Safe swimming area with lifeguards',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'safe', child: Text('Safe Zone')),
                DropdownMenuItem(value: 'danger', child: Text('Danger Zone')),
              ],
              onChanged: (value) {
                if (value != null) {
                  type = value;
                }
              },
              decoration: const InputDecoration(
                labelText: 'Zone Type',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isCreatingGeofence = false;
                _newGeofencePoints = [];
              });
            },
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: grey,
              fontFamily: 'Regular',
            ),
          ),
          ButtonWidget(
            label: 'Save Zone',
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a zone name')),
                );
                return;
              }

              Navigator.pop(context);
              _createGeofenceZone(
                nameController.text,
                type,
                _newGeofencePoints,
                descriptionController.text,
              );
            },
            color: primary,
            textColor: white,
            width: 100,
            height: 40,
            fontSize: 14,
            radius: 8,
          ),
        ],
      ),
    );
  }

  // Show dialog to create alert
  void _showCreateAlertDialog({latlng.LatLng? location}) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String priority = 'medium';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Create Emergency Alert',
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Alert Title',
                hintText: 'e.g., Flash Flood Warning',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Alert Message',
                hintText: 'e.g., Flash flooding reported in downtown area',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: priority,
              items: const [
                DropdownMenuItem(
                    value: 'high', child: Text('High (Emergency)')),
                DropdownMenuItem(
                    value: 'medium', child: Text('Medium (Warning)')),
                DropdownMenuItem(value: 'low', child: Text('Low (Advisory)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  priority = value;
                }
              },
              decoration: const InputDecoration(
                labelText: 'Priority Level',
              ),
            ),
            if (location != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextWidget(
                      text:
                          'Alert will be placed at: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                      fontSize: 12,
                      color: grey,
                      fontFamily: 'Regular',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
              text: 'Cancel',
              fontSize: 14,
              color: grey,
              fontFamily: 'Regular',
            ),
          ),
          ButtonWidget(
            label: 'Create Alert',
            onPressed: () {
              if (titleController.text.isEmpty ||
                  messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fill all fields')),
                );
                return;
              }

              Navigator.pop(context);
              _createEmergencyAlert(
                titleController.text,
                messageController.text,
                priority,
                latitude: location?.latitude,
                longitude: location?.longitude,
              );
            },
            color: Colors.red,
            textColor: white,
            width: 120,
            height: 40,
            fontSize: 14,
            radius: 8,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        foregroundColor: white,
        backgroundColor: primary,
        elevation: 2,
        title: TextWidget(
          text: 'Disaster Preparedness & Weather',
          fontSize: 20,
          color: white,
          fontFamily: 'Bold',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(40),
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(),
            ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextWidget(
                      text: _errorMessage!,
                      fontSize: 14,
                      color: Colors.red,
                      fontFamily: 'Medium',
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Disaster Preparedness & Weather Alerts',
                  fontSize: 28,
                  color: primary,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 12),
                TextWidget(
                  text:
                      'Real-time updates on weather, emergency warnings, and evacuation guides.',
                  fontSize: 16,
                  color: black,
                  fontFamily: 'Regular',
                  align: TextAlign.left,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Map Section (now at the top as requested)
          _buildInteractiveUserMapCard(),

          const SizedBox(height: 32),

          // Weather section with new design
          _buildNewWeatherCard(),

          const SizedBox(height: 40),

          // AI Weather Insights section (keep existing)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: primary, size: 24),
                    const SizedBox(width: 8),
                    TextWidget(
                      text: 'AI Weather Insights',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Suggestion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondary,
                        foregroundColor: black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showEditAISuggestionDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text:
                      'Personalized recommendations based on current weather conditions',
                  fontSize: 14,
                  color: grey,
                  fontFamily: 'Regular',
                ),
                const SizedBox(height: 18),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('ai_suggestions')
                      .where('region', isEqualTo: c.auroraLocationLabel)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      print(snapshot.error);
                      return Center(
                        child: TextWidget(
                          text: 'Failed to load suggestions',
                          fontSize: 14,
                          color: Colors.red,
                          fontFamily: 'Regular',
                        ),
                      );
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return Center(
                        child: TextWidget(
                          text: 'No AI suggestions found.',
                          fontSize: 18,
                          color: grey,
                          fontFamily: 'Regular',
                        ),
                      );
                    }
                    final items = docs
                        .map((d) {
                          final data = d.data();
                          final iconName = (data['icon'] ?? 'cloud').toString();
                          final colorName =
                              (data['color'] ?? 'blue').toString();
                          return {
                            'id': d.id,
                            'title': data['title'] ?? '',
                            'message': data['message'] ?? '',
                            'priority': data['priority'] ?? 'medium',
                            'icon': _resolveIcon(iconName),
                            'color': _resolveColor(colorName),
                            'iconName': iconName,
                            'colorName': colorName,
                          };
                        })
                        .toList()
                        .asMap()
                        .entries
                        .map((e) =>
                            _buildAISuggestionCard(e.value, e.key, isWide))
                        .toList();
                    return Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      children: items,
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Wave Conditions for Surfing
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.waves, color: primary, size: 24),
                    const SizedBox(width: 8),
                    TextWidget(
                      text: 'Surf Conditions',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSurfMetricCard('Wave Height',
                        weatherData['wave_height']!, Icons.height, Colors.blue),
                    _buildSurfMetricCard(
                        'Wave Period',
                        weatherData['wave_period']!,
                        Icons.timer,
                        Colors.purple),
                    _buildSurfMetricCard(
                        'Direction',
                        weatherData['wave_direction']!,
                        Icons.navigation,
                        Colors.orange),
                    _buildSurfMetricCard(
                        'Quality',
                        weatherData['surf_quality']!,
                        Icons.thumb_up,
                        weatherData['surf_quality'] == 'Excellent'
                            ? Colors.green
                            : weatherData['surf_quality'] == 'Good'
                                ? Colors.blue
                                : Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                TextWidget(
                  text: 'Surf Recommendation',
                  fontSize: 16,
                  color: black,
                  fontFamily: 'Bold',
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.surfing, color: Colors.blue, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextWidget(
                          text:
                              'Good surfing conditions today. Waves are consistent with moderate periods. Suitable for intermediate surfers.',
                          fontSize: 14,
                          color: black,
                          fontFamily: 'Regular',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper for surf conditions card
  Widget _buildSurfMetricCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          TextWidget(
            text: label,
            fontSize: 12,
            color: grey,
            fontFamily: 'Regular',
          ),
          TextWidget(
            text: value,
            fontSize: 18,
            color: black,
            fontFamily: 'Bold',
          ),
        ],
      ),
    );
  }

  // Generate surf recommendation based on conditions
  String _getSurfRecommendation() {
    if (_waveCondition.quality == 'excellent') {
      return 'Excellent surfing conditions today! Best times are between 6:00 AM - 10:00 AM when winds are lightest.';
    } else if (_waveCondition.quality == 'good') {
      return 'Good surfing conditions today. Waves are consistent with moderate periods. Suitable for intermediate surfers.';
    } else if (_waveCondition.quality == 'fair') {
      return 'Fair surfing conditions. Waves are somewhat inconsistent. Better for experienced surfers.';
    } else {
      return 'Poor surfing conditions today. Consider other water activities or check back tomorrow.';
    }
  }

  // Build alert card for active alerts
  Widget _buildAlertCard(EmergencyAlert alert) {
    Color color;
    switch (alert.priority) {
      case 'high':
        color = Colors.red;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      default:
        color = Colors.yellow;
    }

    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextWidget(
                  text: alert.title,
                  fontSize: 16,
                  color: black,
                  fontFamily: 'Bold',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextWidget(
              text: alert.message,
              fontSize: 14,
              color: black,
              fontFamily: 'Regular',
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(
                text: DateFormat('MMM d, h:mm a').format(alert.timestamp),
                fontSize: 12,
                color: grey,
                fontFamily: 'Regular',
              ),
              TextWidget(
                text: 'Source: ${alert.source}',
                fontSize: 12,
                color: grey,
                fontFamily: 'Regular',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build visitor activity card
  Widget _buildVisitorActivityCard(VisitorLocation location) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextWidget(
                  text: location.visitorName,
                  fontSize: 16,
                  color: black,
                  fontFamily: 'Bold',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: 'Location: ${location.locationName}',
            fontSize: 14,
            color: black,
            fontFamily: 'Regular',
          ),
          TextWidget(
            text:
                'Coordinates: ${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
            fontSize: 12,
            color: grey,
            fontFamily: 'Regular',
          ),
          const Spacer(),
          TextWidget(
            text: DateFormat('MMM d, h:mm a').format(location.timestamp),
            fontSize: 12,
            color: grey,
            fontFamily: 'Regular',
          ),
        ],
      ),
    );
  }

  // Show dialog for visitor details
  void _showVisitorDetailsDialog(VisitorLocation visitor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: visitor.visitorName,
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Location', visitor.locationName),
            _detailRow('Timestamp',
                DateFormat('MMM d, yyyy h:mm a').format(visitor.timestamp)),
            _detailRow('Coordinates',
                '${visitor.latitude.toStringAsFixed(6)}, ${visitor.longitude.toStringAsFixed(6)}'),

            const SizedBox(height: 16),
            TextWidget(
              text: 'Visitor History',
              fontSize: 16,
              color: black,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            // Mock history data
            _historyItem('Aschente Beach Resort', 'Aug 28, 10:15 AM'),
            _historyItem('Downtown Market', 'Aug 27, 3:45 PM'),
            _historyItem('Aurora Ecopark', 'Aug 27, 11:30 AM'),
          ],
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
      ),
    );
  }

  Widget _historyItem(String location, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.place, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: location,
                  fontSize: 14,
                  color: black,
                  fontFamily: 'Medium',
                ),
                TextWidget(
                  text: time,
                  fontSize: 12,
                  color: grey,
                  fontFamily: 'Regular',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show dialog for alert details
  void _showAlertDetailsDialog(EmergencyAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: alert.title,
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Priority', alert.priority.toUpperCase()),
            _detailRow('Status', alert.status),
            if (alert.latitude != null && alert.longitude != null)
              _detailRow('Coordinates',
                  '${alert.latitude!.toStringAsFixed(6)}, ${alert.longitude!.toStringAsFixed(6)}'),
            _detailRow('Source', alert.source),
            _detailRow('Timestamp',
                DateFormat('MMM d, yyyy h:mm a').format(alert.timestamp)),
            const SizedBox(height: 16),
            TextWidget(
              text: 'Alert Message',
              fontSize: 16,
              color: black,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            TextWidget(
              text: alert.message,
              fontSize: 14,
              color: black,
              fontFamily: 'Regular',
            ),
          ],
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
          ButtonWidget(
            label: 'Resolve Alert',
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection(_alertsCollection)
                  .doc(alert.id)
                  .update({'status': 'resolved'});
              Navigator.pop(context);
            },
            color: Colors.green,
            textColor: white,
            width: 120,
            height: 40,
            fontSize: 14,
            radius: 8,
          ),
        ],
      ),
    );
  }

  // Show dialog for health center details
  void _showHealthCenterDetailsDialog(HealthCenter center) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              center.isHospital ? Icons.local_hospital : Icons.medical_services,
              color: center.isHospital ? Colors.red : Colors.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextWidget(
                text: center.name,
                fontSize: 20,
                color: primary,
                fontFamily: 'Bold',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(
                'Type', center.isHospital ? 'Hospital' : 'Health Center'),
            _detailRow('Address', center.address),
            _detailRow('Contact', center.contactNumber),
            const SizedBox(height: 16),
            TextWidget(
              text: 'Available Services',
              fontSize: 16,
              color: black,
              fontFamily: 'Bold',
            ),
            const SizedBox(height: 8),
            ...center.services.map((service) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      TextWidget(
                        text: service,
                        fontSize: 14,
                        color: black,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                )),
          ],
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
          ButtonWidget(
            label: 'Get Directions',
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open directions
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Directions would be opened here')),
              );
            },
            color: primary,
            textColor: white,
            width: 120,
            height: 40,
            fontSize: 14,
            radius: 8,
          ),
        ],
      ),
    );
  }

  // Show dialog for location options
  void _showLocationOptionsDialog(latlng.LatLng location) {
    // Find nearest health center
    final nearestCenter =
        _findNearestHealthCenter(location.latitude, location.longitude);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Location Options',
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text:
                  'Coordinates: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
              fontSize: 14,
              color: black,
              fontFamily: 'Regular',
            ),
            const SizedBox(height: 16),

            // Nearest health center section
            if (nearestCenter != null) ...[
              TextWidget(
                text: 'Nearest Health Facility',
                fontSize: 16,
                color: black,
                fontFamily: 'Bold',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    nearestCenter.isHospital
                        ? Icons.local_hospital
                        : Icons.medical_services,
                    color: nearestCenter.isHospital ? Colors.red : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: nearestCenter.name,
                          fontSize: 14,
                          color: black,
                          fontFamily: 'Medium',
                        ),
                        TextWidget(
                          text: nearestCenter.address,
                          fontSize: 12,
                          color: grey,
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.directions, size: 16),
                label: const Text('Get Directions'),
                onPressed: () {
                  Navigator.pop(context);
                  // In a real app, this would open directions
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Directions would be opened here')),
                  );
                },
              ),
              const Divider(),
            ],

            const SizedBox(height: 8),
            TextWidget(
              text: 'Actions',
              fontSize: 16,
              color: black,
              fontFamily: 'Bold',
            ),
          ],
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
          ButtonWidget(
            label: 'Create Alert Here',
            onPressed: () {
              Navigator.pop(context);
              _showCreateAlertDialog(location: location);
            },
            color: Colors.red,
            textColor: white,
            width: 140,
            height: 40,
            fontSize: 14,
            radius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentWeatherCard(Map<String, String> weatherData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withOpacity(0.1),
            secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: weatherData['location']!,
                    fontSize: 18,
                    color: black,
                    fontFamily: 'Bold',
                  ),
                  const SizedBox(height: 4),
                  TextWidget(
                    text: weatherData['condition']!,
                    fontSize: 14,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
              Icon(
                Icons.location_on,
                color: primary,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: weatherData['temperature']!,
                    fontSize: 48,
                    color: black,
                    fontFamily: 'Bold',
                  ),
                  TextWidget(
                    text: 'Feels like ${weatherData['feels_like']}',
                    fontSize: 14,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.wb_sunny,
                  color: primary,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsCard(Map<String, String> weatherData) {
    final details = [
      {
        'label': 'Humidity',
        'value': weatherData['humidity']!,
        'icon': Icons.water_drop
      },
      {
        'label': 'Wind Speed',
        'value': weatherData['wind_speed']!,
        'icon': Icons.air
      },
      {
        'label': 'Visibility',
        'value': weatherData['visibility']!,
        'icon': Icons.visibility
      },
      {
        'label': 'UV Index',
        'value': weatherData['uv_index']!,
        'icon': Icons.wb_sunny
      },
      {
        'label': 'Precipitation',
        'value': weatherData['precipitation']!,
        'icon': Icons.cloud
      },
      {
        'label': 'Pressure',
        'value': weatherData['pressure']!,
        'icon': Icons.speed
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Weather Details',
            fontSize: 16,
            color: black,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: details.length,
            itemBuilder: (context, index) {
              final detail = details[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      detail['icon'] as IconData,
                      color: primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: detail['label'].toString(),
                            fontSize: 12,
                            color: grey,
                            fontFamily: 'Regular',
                          ),
                          TextWidget(
                            text: detail['value'].toString(),
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Bold',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestionCard(
      Map<String, dynamic> suggestion, int index, bool isWide) {
    Color priorityColor;
    switch (suggestion['priority']) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return SizedBox(
      width: isWide ? 350 : double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: suggestion['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  suggestion['icon'],
                  color: suggestion['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        TextWidget(
                          text: suggestion['title'],
                          fontSize: 16,
                          color: black,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextWidget(
                            text:
                                suggestion['priority'].toString().toUpperCase(),
                            fontSize: 10,
                            color: priorityColor,
                            fontFamily: 'Bold',
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          color: primary,
                          onPressed: () => _showEditAISuggestionDialog(
                              suggestion: suggestion,
                              docId: suggestion['id'] as String?),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red,
                          onPressed: () =>
                              _deleteAISuggestion(suggestion['id'] as String),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: suggestion['message'],
                      fontSize: 14,
                      color: grey,
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // New weather UI inspired by the provided image
  Widget _buildNewWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location and controls bar
          Row(
            children: [
              TextWidget(
                text: 'Current Location: ${weatherData['location']}',
                fontSize: 16,
                color: black,
                fontFamily: 'Medium',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Current weather with temp and conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side with temp and weather icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Weather icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: (weatherData['condition'] ?? '')
                              .toLowerCase()
                              .contains('thunderstorm')
                          ? const Icon(Icons.flash_on,
                              color: Colors.amber, size: 36)
                          : (weatherData['condition'] ?? '')
                                  .toLowerCase()
                                  .contains('rain')
                              ? const Icon(Icons.grain,
                                  color: Colors.blue, size: 36)
                              : const Icon(Icons.wb_sunny,
                                  color: Colors.amber, size: 36),
                    ),
                    const SizedBox(width: 16),

                    // Temperature
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: (weatherData['temperature'] ?? '0°C')
                                  .replaceAll('°C', ''),
                              fontSize: 48,
                              color: black,
                              fontFamily: 'Bold',
                            ),
                            TextWidget(
                              text: '°C',
                              fontSize: 24,
                              color: black,
                              fontFamily: 'Regular',
                            ),
                            TextWidget(
                              text: '|°F',
                              fontSize: 16,
                              color: grey,
                              fontFamily: 'Regular',
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Weather details
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text:
                                      'Precipitation: ${weatherData['precipitation'] ?? '—'}',
                                  fontSize: 14,
                                  color: grey,
                                  fontFamily: 'Regular',
                                ),
                                TextWidget(
                                  text:
                                      'Humidity: ${weatherData['humidity'] ?? '—'}',
                                  fontSize: 14,
                                  color: grey,
                                  fontFamily: 'Regular',
                                ),
                                TextWidget(
                                  text:
                                      'Wind: ${weatherData['wind_speed'] ?? '—'}',
                                  fontSize: 14,
                                  color: grey,
                                  fontFamily: 'Regular',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Right side with weather title and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextWidget(
                      text: 'Weather',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.right,
                    ),
                    TextWidget(
                      text: weatherData['timestamp'] ??
                          DateFormat('EEEE h:mm a').format(DateTime.now()),
                      fontSize: 16,
                      color: grey,
                      fontFamily: 'Regular',
                      align: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: weatherData['condition'] ?? 'Unknown',
                      fontSize: 18,
                      color: black,
                      fontFamily: 'Medium',
                      align: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Divider
          const Divider(),

          const SizedBox(height: 16),

          // Hourly forecast
          Container(
            height: 100,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomPaint(
                painter: _TemperatureChartPainter(),
                child: Container(),
              ),
            ),
          ),

          // Time slots
          Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeSlot('10 PM'),
                _timeSlot('1 AM'),
                _timeSlot('4 AM'),
                _timeSlot('7 AM'),
                _timeSlot('10 AM'),
                _timeSlot('1 PM'),
                _timeSlot('4 PM'),
                _timeSlot('7 PM'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Day of week forecast
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8, // 7 days + today
              itemBuilder: (context, index) {
                final labels = [
                  'Sun',
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ];
                final highTemps = [
                  '28°',
                  '29°',
                  '28°',
                  '29°',
                  '29°',
                  '29°',
                  '28°',
                  '29°'
                ];
                final lowTemps = [
                  '25°',
                  '25°',
                  '25°',
                  '25°',
                  '25°',
                  '25°',
                  '25°',
                  '24°'
                ];

                bool hasThunderstorm = index == 0 || index == 4 || index == 6;

                return Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextWidget(
                        text: labels[index],
                        fontSize: 14,
                        color: black,
                        fontFamily: 'Medium',
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        hasThunderstorm
                            ? Icons.flash_on
                            : (index % 2 == 0 ? Icons.wb_cloudy : Icons.cloud),
                        color: hasThunderstorm ? Colors.amber : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextWidget(
                            text: highTemps[index],
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Bold',
                          ),
                          TextWidget(
                            text: ' ${lowTemps[index]}',
                            fontSize: 14,
                            color: grey,
                            fontFamily: 'Regular',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Alert banner
          if (_activeAlerts.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber,
                          color: Colors.red, size: 24),
                      const SizedBox(width: 8),
                      TextWidget(
                        text: 'General Flood Advisory (Severe)',
                        fontSize: 18,
                        color: Colors.red,
                        fontFamily: 'Bold',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text: 'Region 3 (Central Luzon)',
                    fontSize: 16,
                    color: black,
                    fontFamily: 'Medium',
                  ),
                  TextWidget(
                    text: '4 hours ago – PAGASA',
                    fontSize: 14,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(height: 8),
                  TextWidget(
                    text:
                        'Under present weather conditions. At 3:00 PM today, the Low Pressure Area (LPA) was estimated based on all available at 675 km East of Borongan City, Eastern Samar (12.5°N, 131...',
                    fontSize: 14,
                    color: black,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // View more info
                    },
                    child: const Text('More info'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Helper to build map legend items
  Widget _buildMapLegendItem(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          TextWidget(
            text: label,
            fontSize: 12,
            color: black,
            fontFamily: 'Medium',
          ),
        ],
      ),
    );
  }

  // Build visitor marker list
  List<Marker> _buildVisitorMarkers() {
    return _visitorLocations.map((visitor) {
      return Marker(
        width: 30,
        height: 30,
        point: latlng.LatLng(visitor.latitude, visitor.longitude),
        child: GestureDetector(
          onTap: () {
            _showVisitorDetailsDialog(visitor);
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_pin_circle,
                color: Colors.blue, size: 24),
          ),
        ),
      );
    }).toList();
  }

  // Build alert marker list
  List<Marker> _buildAlertMarkers() {
    return _activeAlerts
        .where((alert) => alert.latitude != null && alert.longitude != null)
        .map((alert) {
      Color color;
      switch (alert.priority) {
        case 'high':
          color = Colors.red;
          break;
        case 'medium':
          color = Colors.orange;
          break;
        default:
          color = Colors.yellow;
      }

      return Marker(
        width: 36,
        height: 36,
        point: latlng.LatLng(alert.latitude!, alert.longitude!),
        child: GestureDetector(
          onTap: () {
            _showAlertDetailsDialog(alert);
          },
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(Icons.warning_amber, color: color, size: 24),
          ),
        ),
      );
    }).toList();
  }

  // Build health center marker list
  List<Marker> _buildHealthCenterMarkers() {
    return _healthCenters.map((center) {
      return Marker(
        width: 30,
        height: 30,
        point: latlng.LatLng(center.latitude, center.longitude),
        child: GestureDetector(
          onTap: () {
            _showHealthCenterDetailsDialog(center);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: center.isHospital ? Colors.red : Colors.green,
                width: 2,
              ),
            ),
            child: Icon(
              center.isHospital ? Icons.local_hospital : Icons.medical_services,
              color: center.isHospital ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  // Build geofence point markers when creating
  List<Marker> _buildGeofencePointMarkers() {
    if (!_isCreatingGeofence) return [];

    return _newGeofencePoints.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;

      return Marker(
        width: 24,
        height: 24,
        point: point,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: _newGeofenceType == 'safe' ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Center(
            child: TextWidget(
              text: '${index + 1}',
              fontSize: 12,
              color: black,
              fontFamily: 'Bold',
            ),
          ),
        ),
      );
    }).toList();
  }

  // Helper method for time slots in weather chart
  Widget _timeSlot(String time) {
    return TextWidget(
      text: time,
      fontSize: 12,
      color: grey,
      fontFamily: 'Regular',
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
