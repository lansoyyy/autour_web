import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:autour_web/utils/const.dart' as c;
import 'package:cloud_firestore/cloud_firestore.dart';

class DisasterPreparednessAdminScreen extends StatefulWidget {
  const DisasterPreparednessAdminScreen({super.key});

  @override
  State<DisasterPreparednessAdminScreen> createState() =>
      _DisasterPreparednessAdminScreenState();
}

class _DisasterPreparednessAdminScreenState
    extends State<DisasterPreparednessAdminScreen> {
  bool _isLoading = false;
  String? _errorMessage;
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
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
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
        final data = json.decode(response.body) as Map<String, dynamic>;
        final weatherDescription =
            (data['weather']?[0]?['description'] ?? '').toString();
        final double temp = (data['main']?['temp'] ?? 0).toDouble();
        final double feelsLike = (data['main']?['feels_like'] ?? 0).toDouble();
        final int pressure = (data['main']?['pressure'] ?? 0).toInt();
        final int humidity = (data['main']?['humidity'] ?? 0).toInt();
        final double windMs = (data['wind']?['speed'] ?? 0).toDouble();
        final double windKmh = windMs * 3.6;
        final int visibilityM = (data['visibility'] ?? 0).toInt();
        final double visibilityKm = visibilityM > 0 ? visibilityM / 1000.0 : 0;
        final int sunrise = (data['sys']?['sunrise'] ?? 0).toInt();
        final int sunset = (data['sys']?['sunset'] ?? 0).toInt();
        // Precipitation last 1h if present
        String precipitation = '—';
        if (data['rain'] != null && data['rain']['1h'] != null) {
          precipitation = '${(data['rain']['1h'] as num).toString()} mm (1h)';
        }

        final timeFmt = DateFormat('h:mm a');
        String fmtUnix(int ts) {
          if (ts <= 0) return '—';
          return timeFmt
              .format(DateTime.fromMillisecondsSinceEpoch(ts * 1000).toLocal());
        }

        setState(() {
          weatherData = {
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
          };
        });

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
            'precipitation_mm_1h':
                data['rain'] != null ? data['rain']['1h'] : null,
            'pressure_hpa': pressure,
            'updatedAt': FieldValue.serverTimestamp(),
          };
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
        } catch (_) {
          // Ignore persistence errors but keep UI responsive
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: white),
            onPressed: _refreshWeather,
          ),
        ],
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Current Weather',
                  fontSize: 22,
                  color: black,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 18),
                _buildCurrentWeatherCard(weatherData),
                const SizedBox(height: 20),
                _buildWeatherDetailsCard(weatherData),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Interactive Map Integration',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    Icon(Icons.map, color: primary, size: 32),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primary.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Text('Map (integration placeholder)'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 40),
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
}
