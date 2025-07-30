import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';

class DisasterPreparednessAdminScreen extends StatefulWidget {
  const DisasterPreparednessAdminScreen({super.key});

  @override
  State<DisasterPreparednessAdminScreen> createState() =>
      _DisasterPreparednessAdminScreenState();
}

class _DisasterPreparednessAdminScreenState
    extends State<DisasterPreparednessAdminScreen> {
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
    setState(() {
      // For demo, just show a snackbar
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: TextWidget(
          text: 'Weather data refreshed',
          fontSize: 14,
          color: white,
        ),
        backgroundColor: primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditAISuggestionDialog(
      {Map<String, dynamic>? suggestion, int? index}) {
    final titleController =
        TextEditingController(text: suggestion?['title'] ?? '');
    final messageController =
        TextEditingController(text: suggestion?['message'] ?? '');
    String priority = suggestion?['priority'] ?? 'medium';
    Color color = suggestion?['color'] ?? Colors.blue;
    IconData icon = suggestion?['icon'] ?? Icons.cloud;
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
            onPressed: () {
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              setState(() {
                if (suggestion == null) {
                  aiSuggestions.add({
                    'title': titleController.text,
                    'message': messageController.text,
                    'icon': icon,
                    'color': color,
                    'priority': priority,
                  });
                } else if (index != null) {
                  aiSuggestions[index] = {
                    'title': titleController.text,
                    'message': messageController.text,
                    'icon': icon,
                    'color': color,
                    'priority': priority,
                  };
                }
              });
              Navigator.pop(context);
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

  void _deleteAISuggestion(int index) {
    setState(() {
      aiSuggestions.removeAt(index);
    });
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
                aiSuggestions.isEmpty
                    ? Center(
                        child: TextWidget(
                          text: 'No AI suggestions found.',
                          fontSize: 18,
                          color: grey,
                          fontFamily: 'Regular',
                        ),
                      )
                    : Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: aiSuggestions
                            .asMap()
                            .entries
                            .map((entry) => _buildAISuggestionCard(
                                entry.value, entry.key, isWide))
                            .toList(),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Emergency Quick Actions',
                  fontSize: 22,
                  color: black,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 18),
                _buildEmergencyActionsCard(),
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
                              suggestion: suggestion, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          color: Colors.red,
                          onPressed: () => _deleteAISuggestion(index),
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

  Widget _buildEmergencyActionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              TextWidget(
                text: 'Emergency Quick Actions',
                fontSize: 16,
                color: black,
                fontFamily: 'Bold',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  label: 'Send Alert',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: TextWidget(
                          text: 'Emergency alert sent!',
                          fontSize: 14,
                          color: white,
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  color: Colors.red,
                  textColor: white,
                  height: 40,
                  radius: 8,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ButtonWidget(
                  label: 'Evacuation Guide',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: TextWidget(
                          text: 'Evacuation guide sent!',
                          fontSize: 14,
                          color: white,
                        ),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  color: Colors.orange,
                  textColor: white,
                  height: 40,
                  radius: 8,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
