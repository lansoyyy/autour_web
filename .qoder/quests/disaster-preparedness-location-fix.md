# Disaster Preparedness Location Fix Design Document

## 1. Overview

This document outlines the design for fixing the location-based weather data refresh issue in the disaster preparedness admin screen. The current implementation has a static location (Baler, Aurora) hardcoded in the constants file, which prevents real-time location updates even when GPS functionality is active.

The solution involves implementing dynamic location detection using the device's GPS capabilities, refreshing weather data based on the current location, and adding additional marine and atmospheric data fields as required.

## 2. Current Issues

1. **Location Refresh Problem**: Real-time weather data for surrounding municipalities does not refresh during testing, even with GPS functionality active.
2. **Static Location**: The app incorrectly displays the location as Baler regardless of the actual device location (e.g., Dilasag, Aurora).
3. **Missing Data Fields**: The application lacks several required marine and atmospheric data fields:
   - Tide levels and timing
   - Wave height and period
   - Swell direction and size
   - Water temperature
   - UV index
   - Atmospheric Pressure and Fronts
4. **Audio Alert**: Missing loud tone alert for emergency notifications.

## 3. Architecture

The solution will modify the existing disaster preparedness admin screen to incorporate dynamic location detection and enhanced weather data display. The architecture will follow this flow:

``mermaid
graph TD
    A[DisasterPreparednessAdminScreen] --> B[LocationService]
    B --> C[GPS/Geolocation Detection]
    C --> D[Current Location Coordinates]
    D --> E[Weather API Service]
    E --> F[OpenWeatherMap API]
    F --> G[Enhanced Weather Data]
    G --> H[UI Update with New Data]
    G --> I[Audio Alert System]
```

### 3.1 Component Architecture

1. **Location Service Component**: Handles GPS location detection and updates
2. **Weather Service Component**: Fetches weather data based on current location
3. **Audio Alert Component**: Plays loud tone alerts for emergency notifications
4. **UI Components**: Display enhanced weather information including new data fields

### 3.2 Data Flow

1. Application initializes and requests location permissions
2. Device GPS provides current coordinates
3. Coordinates are used to fetch weather data from OpenWeatherMap API
4. Enhanced weather data is processed and displayed in UI
5. Emergency conditions trigger audio alerts

## 4. Implementation Details

### 4.1 Location Detection Enhancement

We need to add the `geolocator` package to the `pubspec.yaml` file:

```yaml
dependencies:
  geolocator: ^13.0.1
```

Then implement dynamic location detection in the `DisasterPreparednessAdminScreen`:

1. Add location permission handling
2. Implement current location detection
3. Update weather data when location changes
4. Add location fallback mechanisms

The current implementation uses hardcoded coordinates from `const.dart`:
```dart
const double auroraLat = 15.7589;
const double auroraLon = 121.5623;
const String auroraLocationLabel = 'Baler, Aurora';
```

We need to implement dynamic location detection using a geolocation package like `geolocator`.

### 4.2 Weather Data Enhancement

Extend the existing `weatherData` map in the state to include new fields:

```dart
Map<String, String> weatherData = {
  // Existing fields...
  'location': 'Baler, Aurora',
  'temperature': '28°C',
  // ... other existing fields
  
  // New marine data fields
  'tide_level': '1.2m',
  'tide_timing': 'High tide at 14:30',
  'wave_height': '1.2m',
  'wave_period': '8.5s',
  'swell_direction': 'NE',
  'swell_size': '1.5m',
  'water_temperature': '27°C',
  
  // New atmospheric data fields
  'uv_index': 'High',
  'pressure': '1013 hPa',
  'atmospheric_fronts': 'Stable',
};
```

Update the `_fetchWeather()` method to fetch enhanced data from multiple API endpoints.

Current weather data structure needs to be extended to include:
- Tide levels and timing
- Wave height and period
- Swell direction and size
- Water temperature
- UV index
- Atmospheric Pressure and Fronts

### 4.3 Audio Alert Implementation

Enhance the existing `_playAlertSound()` method to ensure it plays a loud, attention-grabbing tone:

```dart
// Audio controller for emergency alerts
html.AudioElement? _alertSound;

// Play high-pitched alert sound
void _playAlertSound() {
  try {
    _alertSound = html.AudioElement();
    _alertSound?.src = 'assets/sounds/alert.mp3';
    _alertSound?.volume = 1.0; // Maximum volume
    _alertSound?.play();
  } catch (e) {
    print('Error playing alert sound: $e');
  }
}
```

Ensure the `assets/sounds/alert.mp3` file exists in the project with an appropriate loud alert tone.

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management

1. **Initialize Location Service**: Add location initialization in `initState()` method
2. **Request Permissions**: Implement permission request flow for location access
3. **Get Current Location**: Use `geolocator` package to get current device location
4. **Handle Location Updates**: Listen for location changes and update weather data
5. **Fallback Mechanism**: Use default location if GPS is unavailable or denied

Implementation example:

```dart
Future<void> _getCurrentLocation() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      _useDefaultLocation();
      return;
    }
    
    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied
        _useDefaultLocation();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions permanently denied
      _useDefaultLocation();
      return;
    }
    
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    setState(() {
      _currentLocation = latlng.LatLng(position.latitude, position.longitude);
    });
    
    // Update weather data with new location
    _fetchWeather();
  } catch (e) {
    print('Error getting location: $e');
    _useDefaultLocation();
  }
}

void _useDefaultLocation() {
  setState(() {
    _currentLocation = latlng.LatLng(c.auroraLat, c.auroraLon);
    weatherData['location'] = c.auroraLocationLabel;
  });
  _fetchWeather();
}
```

### 7.2 Weather Data Management

1. **Multi-API Data Fetching**: Extend `_fetchWeather()` to call multiple API endpoints
2. **Data Processing**: Parse and format data from different API responses
3. **State Management**: Update state with enhanced weather data
4. **Error Handling**: Implement robust error handling for API calls

Implementation example:

```dart
Future<void> _fetchWeather() async {
  if (c.weatherApiKey.isEmpty) {
    // Handle missing API key
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // Fetch current weather data
    final currentWeatherUri = Uri.parse(
        '${c.weatherApiEndpoint}?lat=${_currentLocation.latitude}&lon=${_currentLocation.longitude}&appid=${c.weatherApiKey}&units=metric');
    
    final currentResponse = await http.get(currentWeatherUri);
    
    if (currentResponse.statusCode == 200) {
      // Process current weather data
      final data = json.decode(currentResponse.body) as Map<String, dynamic>;
      
      // Extract weather data with null safety
      final weatherDescription = (data['weather']?[0]?['description'] ?? '').toString();
      final double temp = (data['main']?['temp'] ?? 0).toDouble();
      // ... other current weather data extraction
      
      // Update UI data
      final Map<String, String> updatedWeatherData = {
        // ... existing fields
        'uv_index': _fetchUVIndex(_currentLocation.latitude, _currentLocation.longitude),
        'tide_level': _fetchTideData(_currentLocation.latitude, _currentLocation.longitude),
        // ... other new fields
      };
      
      setState(() {
        weatherData = updatedWeatherData;
      });
    }
    
    // Check for bad weather conditions after updating weather data
    _checkBadWeatherAndAlert();
  } catch (e) {
    setState(() {
      _errorMessage = 'Error: $e';
    });
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Helper methods for fetching additional data
Future<String> _fetchUVIndex(double lat, double lon) async {
  // Implementation for fetching UV index
  return 'High';
}

Future<String> _fetchTideData(double lat, double lon) async {
  // Implementation for fetching tide data
  return '1.2m';
}
```

### 7.3 Alert System

1. **Condition Monitoring**: Extend `_checkBadWeatherAndAlert()` to monitor additional conditions
2. **Audio Alert Triggering**: Ensure loud tone is played for emergency conditions
3. **Visual Alert Display**: Show prominent notifications in UI

Implementation example:

```dart
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
    final isHighWind = windSpeed >= 50; // 50 km/h or more is considered high wind
    
    // Check for dangerous marine conditions
    final waveHeightStr = weatherData['wave_height'] ?? '';
    final waveHeight = _extractNumberFromText(waveHeightStr);
    final isDangerousWaves = waveHeight >= 3.0; // 3m or higher waves are dangerous
    
    // Play alert if bad weather is detected
    if (isBadWeather || isHighWind || isDangerousWaves) {
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
```

## 8. UI Components

### 8.1 Enhanced Weather Display

Update the UI to display the new weather data fields:

1. **Marine Conditions Section**:
   - Add tide level and timing display
   - Add wave height and period information
   - Add swell direction and size data
   - Add water temperature display

2. **Atmospheric Conditions Section**:
   - Add UV index display with color coding
   - Add atmospheric pressure information
   - Add front information display

3. **Location Information**:
   - Add current location display that updates with GPS
   - Add GPS status indicator
   - Add refresh button to manually update location

Implementation example for new UI components:

```dart
Widget _buildMarineConditionsCard() {
  return Container(
    padding: const EdgeInsets.all(16),
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
            Icon(Icons.waves, color: primary, size: 24),
            const SizedBox(width: 8),
            TextWidget(
              text: 'Marine Conditions',
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
            _buildMarineMetricCard('Tide Level', weatherData['tide_level']!, Icons.water, Colors.blue),
            _buildMarineMetricCard('Wave Height', weatherData['wave_height']!, Icons.waves, Colors.lightBlue),
            _buildMarineMetricCard('Water Temp', weatherData['water_temperature']!, Icons.water_drop, Colors.cyan),
          ],
        ),
      ],
    ),
  );
}

Widget _buildAtmosphericConditionsCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.air, color: primary, size: 24),
            const SizedBox(width: 8),
            TextWidget(
              text: 'Atmospheric Conditions',
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
            _buildAtmosphericMetricCard('UV Index', weatherData['uv_index']!, Icons.wb_sunny, Colors.orange),
            _buildAtmosphericMetricCard('Pressure', weatherData['pressure']!, Icons.speed, Colors.deepOrange),
          ],
        ),
      ],
    ),
  );
}
```

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests

1. **Location Service Tests**:
   - Test location permission handling
   - Test current location retrieval
   - Test fallback to default location
   - Test location update triggers

2. **Weather Data Tests**:
   - Test API data fetching and parsing
   - Test error handling for failed API calls
   - Test data formatting for UI display
   - Test enhanced data field processing

3. **Alert System Tests**:
   - Test emergency condition detection
   - Test audio alert triggering
   - Test visual alert display
   - Test alert volume settings

Example test cases:

```dart
group('Location Service Tests', () {
  test('should return default location when GPS is disabled', () async {
    // Mock geolocator to return service disabled
    // Verify that default location is used
  });
  
  test('should fetch current location when permissions granted', () async {
    // Mock geolocator to return current position
    // Verify that location is correctly updated
  });
  
  test('should fallback to default location when permissions denied', () async {
    // Mock geolocator to return permission denied
    // Verify that default location is used
  });
});

group('Weather Data Tests', () {
  test('should fetch enhanced weather data', () async {
    // Mock HTTP responses for weather APIs
    // Verify that all data fields are correctly parsed
  });
  
  test('should handle API errors gracefully', () async {
    // Mock HTTP errors
    // Verify that error state is properly handled
  });
});

group('Alert System Tests', () {
  test('should trigger audio alert for severe conditions', () async {
    // Set up severe weather conditions
    // Verify that audio alert is triggered
  });
  
  test('should display visual alert for emergency conditions', () async {
    // Set up emergency conditions
    // Verify that visual alert is displayed
  });
});
```

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display

## 10. Implementation Steps

1. **Add Dependencies**:
   - Add `geolocator` package to `pubspec.yaml`
   - Run `flutter pub get` to install dependencies

2. **Update Constants**:
   - Modify location handling in `const.dart` to support dynamic locations

3. **Implement Location Service**:
   - Add location permission handling
   - Implement current location detection
   - Add fallback mechanisms

4. **Enhance Weather Data**:
   - Extend weather data model with new fields
   - Update API fetching logic
   - Add data processing for new fields

5. **Implement Audio Alerts**:
   - Enhance alert sound functionality
   - Add volume controls
   - Test audio playback

6. **Update UI Components**:
   - Add new sections for marine and atmospheric data
   - Implement location status indicators
   - Update existing weather display components

7. **Testing**:
   - Implement unit tests for new functionality
   - Conduct integration testing
   - Perform UI testing across devices

8. **Deployment**:
   - Verify functionality on all supported platforms
   - Update documentation
   - Deploy to production

Implementation example:

```dart
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
    final isHighWind = windSpeed >= 50; // 50 km/h or more is considered high wind
    
    // Check for dangerous marine conditions
    final waveHeightStr = weatherData['wave_height'] ?? '';
    final waveHeight = _extractNumberFromText(waveHeightStr);
    final isDangerousWaves = waveHeight >= 3.0; // 3m or higher waves are dangerous
    
    // Play alert if bad weather is detected
    if (isBadWeather || isHighWind || isDangerousWaves) {
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
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display

Update the UI to display the new weather data fields:

1. **Marine Conditions Section**:
   - Add tide level and timing display
   - Add wave height and period information
   - Add swell direction and size data
   - Add water temperature display

2. **Atmospheric Conditions Section**:
   - Add UV index display with color coding
   - Add atmospheric pressure information
   - Add front information display

3. **Location Information**:
   - Add current location display that updates with GPS
   - Add GPS status indicator
   - Add refresh button to manually update location

Implementation example for new UI components:

```dart
Widget _buildMarineConditionsCard() {
  return Container(
    padding: const EdgeInsets.all(16),
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
            Icon(Icons.waves, color: primary, size: 24),
            const SizedBox(width: 8),
            TextWidget(
              text: 'Marine Conditions',
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
            _buildMarineMetricCard('Tide Level', weatherData['tide_level']!, Icons.water, Colors.blue),
            _buildMarineMetricCard('Wave Height', weatherData['wave_height']!, Icons.waves, Colors.lightBlue),
            _buildMarineMetricCard('Water Temp', weatherData['water_temperature']!, Icons.water_drop, Colors.cyan),
          ],
        ),
      ],
    ),
  );
}

Widget _buildAtmosphericConditionsCard() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.orange.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.air, color: primary, size: 24),
            const SizedBox(width: 8),
            TextWidget(
              text: 'Atmospheric Conditions',
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
            _buildAtmosphericMetricCard('UV Index', weatherData['uv_index']!, Icons.wb_sunny, Colors.orange),
            _buildAtmosphericMetricCard('Pressure', weatherData['pressure']!, Icons.speed, Colors.deepOrange),
          ],
        ),
      ],
    ),
  );
}
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display// Audio controller for emergency alerts
html.AudioElement? _alertSound;

// Play high-pitched alert sound
void _playAlertSound() {
  try {
    _alertSound = html.AudioElement();
    _alertSound?.src = 'assets/sounds/alert.mp3';
    _alertSound?.volume = 1.0; // Maximum volume
    _alertSound?.play();
  } catch (e) {
    print('Error playing alert sound: $e');
  }
}
```

Ensure the `assets/sounds/alert.mp3` file exists in the project with an appropriate loud alert tone.

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management

1. **Initialize Location Service**: Add location initialization in `initState()` method
2. **Request Permissions**: Implement permission request flow for location access
3. **Get Current Location**: Use `geolocator` package to get current device location
4. **Handle Location Updates**: Listen for location changes and update weather data
5. **Fallback Mechanism**: Use default location if GPS is unavailable or denied

Implementation example:

```dart
Future<void> _getCurrentLocation() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      _useDefaultLocation();
      return;
    }
    
    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied
        _useDefaultLocation();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions permanently denied
      _useDefaultLocation();
      return;
    }
    
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    setState(() {
      _currentLocation = latlng.LatLng(position.latitude, position.longitude);
    });
    
    // Update weather data with new location
    _fetchWeather();
  } catch (e) {
    print('Error getting location: $e');
    _useDefaultLocation();
  }
}

void _useDefaultLocation() {
  setState(() {
    _currentLocation = latlng.LatLng(c.auroraLat, c.auroraLon);
    weatherData['location'] = c.auroraLocationLabel;
  });
  _fetchWeather();
}
1. Check and request location permissions
2. Get current device location using GPS
3. Handle location permission denied scenarios
4. Fallback to default location if GPS is unavailable

### 7.2 Weather Data Management

1. **Multi-API Data Fetching**: Extend `_fetchWeather()` to call multiple API endpoints
2. **Data Processing**: Parse and format data from different API responses
3. **State Management**: Update state with enhanced weather data
4. **Error Handling**: Implement robust error handling for API calls

Implementation example:

```dart
Future<void> _fetchWeather() async {
  if (c.weatherApiKey.isEmpty) {
    // Handle missing API key
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // Fetch current weather data
    final currentWeatherUri = Uri.parse(
        '${c.weatherApiEndpoint}?lat=${_currentLocation.latitude}&lon=${_currentLocation.longitude}&appid=${c.weatherApiKey}&units=metric');
    
    final currentResponse = await http.get(currentWeatherUri);
    
    if (currentResponse.statusCode == 200) {
      // Process current weather data
      final data = json.decode(currentResponse.body) as Map<String, dynamic>;
      
      // Extract weather data with null safety
      final weatherDescription = (data['weather']?[0]?['description'] ?? '').toString();
      final double temp = (data['main']?['temp'] ?? 0).toDouble();
      // ... other current weather data extraction
      
      // Update UI data
      final Map<String, String> updatedWeatherData = {
        // ... existing fields
        'uv_index': _fetchUVIndex(_currentLocation.latitude, _currentLocation.longitude),
        'tide_level': _fetchTideData(_currentLocation.latitude, _currentLocation.longitude),
        // ... other new fields
      };
      
      setState(() {
        weatherData = updatedWeatherData;
      });
    }
    
    // Check for bad weather conditions after updating weather data
    _checkBadWeatherAndAlert();
  } catch (e) {
    setState(() {
      _errorMessage = 'Error: $e';
    });
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Helper methods for fetching additional data
Future<String> _fetchUVIndex(double lat, double lon) async {
  // Implementation for fetching UV index
  return 'High';
}

Future<String> _fetchTideData(double lat, double lon) async {
  // Implementation for fetching tide data
  return '1.2m';
}
1. Fetch current weather data based on location
2. Fetch 5-day forecast data
3. Fetch marine weather data
4. Process and format data for UI display
5. Store data in state for UI rendering

### 7.3 Alert System

1. **Condition Monitoring**: Extend `_checkBadWeatherAndAlert()` to monitor additional conditions
2. **Audio Alert Triggering**: Ensure loud tone is played for emergency conditions
3. **Visual Alert Display**: Show prominent notifications in UI

Implementation example:

```dart
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
    final isHighWind = windSpeed >= 50; // 50 km/h or more is considered high wind
    
    // Check for dangerous marine conditions
    final waveHeightStr = weatherData['wave_height'] ?? '';
    final waveHeight = _extractNumberFromText(waveHeightStr);
    final isDangerousWaves = waveHeight >= 3.0; // 3m or higher waves are dangerous
    
    // Play alert if bad weather is detected
    if (isBadWeather || isHighWind || isDangerousWaves) {
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
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display// Audio controller for emergency alerts
html.AudioElement? _alertSound;

// Play high-pitched alert sound
void _playAlertSound() {
  try {
    _alertSound = html.AudioElement();
    _alertSound?.src = 'assets/sounds/alert.mp3';
    _alertSound?.volume = 1.0; // Maximum volume
    _alertSound?.play();
  } catch (e) {
    print('Error playing alert sound: $e');
  }
}
```

Ensure the `assets/sounds/alert.mp3` file exists in the project with an appropriate loud alert tone.

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management

1. **Initialize Location Service**: Add location initialization in `initState()` method
2. **Request Permissions**: Implement permission request flow for location access
3. **Get Current Location**: Use `geolocator` package to get current device location
4. **Handle Location Updates**: Listen for location changes and update weather data
5. **Fallback Mechanism**: Use default location if GPS is unavailable or denied

Implementation example:

```dart
Future<void> _getCurrentLocation() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      _useDefaultLocation();
      return;
    }
    
    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied
        _useDefaultLocation();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions permanently denied
      _useDefaultLocation();
      return;
    }
    
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    setState(() {
      _currentLocation = latlng.LatLng(position.latitude, position.longitude);
    });
    
    // Update weather data with new location
    _fetchWeather();
  } catch (e) {
    print('Error getting location: $e');
    _useDefaultLocation();
  }
}

void _useDefaultLocation() {
  setState(() {
    _currentLocation = latlng.LatLng(c.auroraLat, c.auroraLon);
    weatherData['location'] = c.auroraLocationLabel;
  });
  _fetchWeather();
}
1. Check and request location permissions
2. Get current device location using GPS
3. Handle location permission denied scenarios
4. Fallback to default location if GPS is unavailable

### 7.2 Weather Data Management

1. **Multi-API Data Fetching**: Extend `_fetchWeather()` to call multiple API endpoints
2. **Data Processing**: Parse and format data from different API responses
3. **State Management**: Update state with enhanced weather data
4. **Error Handling**: Implement robust error handling for API calls

Implementation example:

```dart
Future<void> _fetchWeather() async {
  if (c.weatherApiKey.isEmpty) {
    // Handle missing API key
    return;
  }

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // Fetch current weather data
    final currentWeatherUri = Uri.parse(
        '${c.weatherApiEndpoint}?lat=${_currentLocation.latitude}&lon=${_currentLocation.longitude}&appid=${c.weatherApiKey}&units=metric');
    
    final currentResponse = await http.get(currentWeatherUri);
    
    if (currentResponse.statusCode == 200) {
      // Process current weather data
      final data = json.decode(currentResponse.body) as Map<String, dynamic>;
      
      // Extract weather data with null safety
      final weatherDescription = (data['weather']?[0]?['description'] ?? '').toString();
      final double temp = (data['main']?['temp'] ?? 0).toDouble();
      // ... other current weather data extraction
      
      // Update UI data
      final Map<String, String> updatedWeatherData = {
        // ... existing fields
        'uv_index': _fetchUVIndex(_currentLocation.latitude, _currentLocation.longitude),
        'tide_level': _fetchTideData(_currentLocation.latitude, _currentLocation.longitude),
        // ... other new fields
      };
      
      setState(() {
        weatherData = updatedWeatherData;
      });
    }
    
    // Check for bad weather conditions after updating weather data
    _checkBadWeatherAndAlert();
  } catch (e) {
    setState(() {
      _errorMessage = 'Error: $e';
    });
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Helper methods for fetching additional data
Future<String> _fetchUVIndex(double lat, double lon) async {
  // Implementation for fetching UV index
  return 'High';
}

Future<String> _fetchTideData(double lat, double lon) async {
  // Implementation for fetching tide data
  return '1.2m';
}
1. Fetch current weather data based on location
2. Fetch 5-day forecast data
3. Fetch marine weather data
4. Process and format data for UI display
5. Store data in state for UI rendering

### 7.3 Alert System
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display// Audio controller for emergency alerts
html.AudioElement? _alertSound;

// Play high-pitched alert sound
void _playAlertSound() {
  try {
    _alertSound = html.AudioElement();
    _alertSound?.src = 'assets/sounds/alert.mp3';
    _alertSound?.volume = 1.0; // Maximum volume
    _alertSound?.play();
  } catch (e) {
    print('Error playing alert sound: $e');
  }
}
```

Ensure the `assets/sounds/alert.mp3` file exists in the project with an appropriate loud alert tone.

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management

1. **Initialize Location Service**: Add location initialization in `initState()` method
2. **Request Permissions**: Implement permission request flow for location access
3. **Get Current Location**: Use `geolocator` package to get current device location
4. **Handle Location Updates**: Listen for location changes and update weather data
5. **Fallback Mechanism**: Use default location if GPS is unavailable or denied

Implementation example:

```dart
Future<void> _getCurrentLocation() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      _useDefaultLocation();
      return;
    }
    
    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions denied
        _useDefaultLocation();
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions permanently denied
      _useDefaultLocation();
      return;
    }
    
    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    setState(() {
      _currentLocation = latlng.LatLng(position.latitude, position.longitude);
    });
    
    // Update weather data with new location
    _fetchWeather();
  } catch (e) {
    print('Error getting location: $e');
    _useDefaultLocation();
  }
}

void _useDefaultLocation() {
  setState(() {
    _currentLocation = latlng.LatLng(c.auroraLat, c.auroraLon);
    weatherData['location'] = c.auroraLocationLabel;
  });
  _fetchWeather();
}
1. Check and request location permissions
2. Get current device location using GPS
3. Handle location permission denied scenarios
4. Fallback to default location if GPS is unavailable

### 7.2 Weather Data Management
1. Fetch current weather data based on location
2. Fetch 5-day forecast data
3. Fetch marine weather data
4. Process and format data for UI display
5. Store data in state for UI rendering

### 7.3 Alert System
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display};
```

Update the `_fetchWeather()` method to fetch enhanced data from multiple API endpoints.

Current weather data structure needs to be extended to include:
- Tide levels and timing
- Wave height and period
- Swell direction and size
- Water temperature
- UV index
- Atmospheric Pressure and Fronts

### 4.3 Audio Alert Implementation

Enhance the existing `_playAlertSound()` method to ensure it plays a loud, attention-grabbing tone:

```dart
// Audio controller for emergency alerts
html.AudioElement? _alertSound;

// Play high-pitched alert sound
void _playAlertSound() {
  try {
    _alertSound = html.AudioElement();
    _alertSound?.src = 'assets/sounds/alert.mp3';
    _alertSound?.volume = 1.0; // Maximum volume
    _alertSound?.play();
  } catch (e) {
    print('Error playing alert sound: $e');
  }
}
```

Ensure the `assets/sounds/alert.mp3` file exists in the project with an appropriate loud alert tone.

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management
1. Check and request location permissions
2. Get current device location using GPS
3. Handle location permission denied scenarios
4. Fallback to default location if GPS is unavailable

### 7.2 Weather Data Management
1. Fetch current weather data based on location
2. Fetch 5-day forecast data
3. Fetch marine weather data
4. Process and format data for UI display
5. Store data in state for UI rendering

### 7.3 Alert System
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification displayExtend the existing `weatherData` map in the state to include new fields:

```dart
Map<String, String> weatherData = {
  // Existing fields...
  'location': 'Baler, Aurora',
  'temperature': '28°C',
  // ... other existing fields
  
  // New marine data fields
  'tide_level': '1.2m',
  'tide_timing': 'High tide at 14:30',
  'wave_height': '1.2m',
  'wave_period': '8.5s',
  'swell_direction': 'NE',
  'swell_size': '1.5m',
  'water_temperature': '27°C',
  
  // New atmospheric data fields
  'uv_index': 'High',
  'pressure': '1013 hPa',
  'atmospheric_fronts': 'Stable',
};
```

Update the `_fetchWeather()` method to fetch enhanced data from multiple API endpoints.

Current weather data structure needs to be extended to include:
- Tide levels and timing
- Wave height and period
- Swell direction and size
- Water temperature
- UV index
- Atmospheric Pressure and Fronts

### 4.3 Audio Alert Implementation

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management
1. Check and request location permissions
2. Get current device location using GPS
3. Handle location permission denied scenarios
4. Fallback to default location if GPS is unavailable

### 7.2 Weather Data Management
1. Fetch current weather data based on location
2. Fetch 5-day forecast data
3. Fetch marine weather data
4. Process and format data for UI display
5. Store data in state for UI rendering

### 7.3 Alert System
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display3. Update weather data when location changes
4. Add location fallback mechanisms

The current implementation uses hardcoded coordinates from `const.dart`:
```dart
const double auroraLat = 15.7589;
const double auroraLon = 121.5623;
const String auroraLocationLabel = 'Baler, Aurora';
```

We need to implement dynamic location detection using a geolocation package like `geolocator`.

### 4.2 Weather Data Enhancement

Current weather data structure needs to be extended to include:
- Tide levels and timing
- Wave height and period
- Swell direction and size
- Water temperature
- UV index
- Atmospheric Pressure and Fronts

### 4.3 Audio Alert Implementation

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management
1. Check and request location permissions
2. Get current device location using GPS
3. Handle location permission denied scenarios
4. Fallback to default location if GPS is unavailable

### 7.2 Weather Data Management
1. Fetch current weather data based on location
2. Fetch 5-day forecast data
3. Fetch marine weather data
4. Process and format data for UI display
5. Store data in state for UI rendering

### 7.3 Alert System
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display4. Enhanced weather data is processed and displayed in UI
5. Emergency conditions trigger audio alerts

## 4. Implementation Details

### 4.1 Location Detection Enhancement

The current implementation uses hardcoded coordinates from `const.dart`:
```dart
const double auroraLat = 15.7589;
const double auroraLon = 121.5623;
const String auroraLocationLabel = 'Baler, Aurora';
```

We need to implement dynamic location detection using a geolocation package like `geolocator`.

### 4.2 Weather Data Enhancement

Current weather data structure needs to be extended to include:
- Tide levels and timing
- Wave height and period
- Swell direction and size
- Water temperature
- UV index
- Atmospheric Pressure and Fronts

### 4.3 Audio Alert Implementation

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management
1. Check and request location permissions
2. Get current device location using GPS
3. Handle location permission denied scenarios
4. Fallback to default location if GPS is unavailable

### 7.2 Weather Data Management
1. Fetch current weather data based on location
2. Fetch 5-day forecast data
3. Fetch marine weather data
4. Process and format data for UI display
5. Store data in state for UI rendering

### 7.3 Alert System
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display    G --> H[UI Update with New Data]
    G --> I[Audio Alert System]
```

### 3.1 Component Architecture

1. **Location Service Component**: Handles GPS location detection and updates
2. **Weather Service Component**: Fetches weather data based on current location
3. **Audio Alert Component**: Plays loud tone alerts for emergency notifications
4. **UI Components**: Display enhanced weather information including new data fields

### 3.2 Data Flow

1. Application initializes and requests location permissions
2. Device GPS provides current coordinates
3. Coordinates are used to fetch weather data from OpenWeatherMap API
4. Enhanced weather data is processed and displayed in UI
5. Emergency conditions trigger audio alerts

## 4. Implementation Details

### 4.1 Location Detection Enhancement

The current implementation uses hardcoded coordinates from `const.dart`:
```dart
const double auroraLat = 15.7589;
const double auroraLon = 121.5623;
const String auroraLocationLabel = 'Baler, Aurora';
```

We need to implement dynamic location detection using a geolocation package like `geolocator`.

### 4.2 Weather Data Enhancement

Current weather data structure needs to be extended to include:
- Tide levels and timing
- Wave height and period
- Swell direction and size
- Water temperature
- UV index
- Atmospheric Pressure and Fronts

### 4.3 Audio Alert Implementation

Add loud tone alert functionality for emergency notifications using HTML5 Audio API.

## 5. API Endpoints Reference

### 5.1 Current Weather API
```
GET https://api.openweathermap.org/data/2.5/weather?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.2 5-Day Forecast API
```
GET https://api.openweathermap.org/data/2.5/forecast?lat={lat}&lon={lon}&appid={API_KEY}&units=metric
```

### 5.3 Marine Weather API (New)
```
GET https://api.openweathermap.org/data/2.5/marine/forecast?lat={lat}&lon={lon}&appid={API_KEY}
```

## 6. Data Models

### 6.1 Enhanced Weather Data Model
```dart
class EnhancedWeatherData {
  final String location;
  final double temperature;
  final double feelsLike;
  final String condition;
  final int humidity;
  final double windSpeed;
  final double visibility;
  final int uvIndex;
  final String sunrise;
  final String sunset;
  final String precipitation;
  final int pressure;
  
  // New marine data fields
  final double tideLevel;
  final String tideTiming;
  final double waveHeight;
  final double wavePeriod;
  final String swellDirection;
  final double swellSize;
  final double waterTemperature;
  
  // New atmospheric data fields
  final String atmosphericFronts;
  
  // Timestamp
  final DateTime timestamp;
}
```

### 6.2 Location Model
```dart
class UserLocation {
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
}
```

## 7. Business Logic Layer

### 7.1 Location Management
1. Check and request location permissions
2. Get current device location using GPS
3. Handle location permission denied scenarios
4. Fallback to default location if GPS is unavailable

### 7.2 Weather Data Management
1. Fetch current weather data based on location
2. Fetch 5-day forecast data
3. Fetch marine weather data
4. Process and format data for UI display
5. Store data in state for UI rendering

### 7.3 Alert System
1. Monitor weather conditions for emergency thresholds
2. Trigger audio alerts for severe conditions
3. Display visual alerts in UI

## 8. UI Components

### 8.1 Enhanced Weather Display
- Location-based current weather with temperature and conditions
- 5-day forecast with detailed information
- Marine conditions section (tides, waves, swell)
- Atmospheric conditions section (pressure, UV index)
- Emergency alerts with audio notifications

### 8.2 Location Status Indicator
- Current location display
- GPS status indicator
- Manual location override option

## 9. Testing

### 9.1 Unit Tests
1. Test location service functionality
2. Test weather data fetching and processing
3. Test emergency condition detection
4. Test audio alert triggering

### 9.2 Integration Tests
1. Test complete flow from location detection to UI display
2. Test emergency alert system end-to-end
3. Test fallback mechanisms for location services

### 9.3 UI Tests
1. Test weather data display components
2. Test responsive design across different screen sizes
3. Test alert notification display

## 10. Implementation Steps

1. **Add Dependencies**:
   - Add `geolocator` package to `pubspec.yaml`
   - Run `flutter pub get` to install dependencies

2. **Update Constants**:
   - Modify location handling in `const.dart` to support dynamic locations

3. **Implement Location Service**:
   - Add location permission handling
   - Implement current location detection
   - Add fallback mechanisms

4. **Enhance Weather Data**:
   - Extend weather data model with new fields
   - Update API fetching logic
   - Add data processing for new fields

5. **Implement Audio Alerts**:
   - Enhance alert sound functionality
   - Add volume controls
   - Test audio playback

6. **Update UI Components**:
   - Add new sections for marine and atmospheric data
   - Implement location status indicators
   - Update existing weather display components

7. **Testing**:
   - Implement unit tests for new functionality
   - Conduct integration testing
   - Perform UI testing across devices

8. **Deployment**:
   - Verify functionality on all supported platforms
   - Update documentation
   - Deploy to production






























































































































































































