import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';

class HealthSurveillanceAdminScreen extends StatefulWidget {
  const HealthSurveillanceAdminScreen({super.key});

  @override
  State<HealthSurveillanceAdminScreen> createState() =>
      _HealthSurveillanceAdminScreenState();
}

class _HealthSurveillanceAdminScreenState
    extends State<HealthSurveillanceAdminScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  // Mock data for health declarations
  List<Map<String, dynamic>> healthDeclarations = [
    {
      'name': 'Juan Dela Cruz',
      'temperature': '36.8',
      'symptoms': 'None',
      'exposure': 'None',
      'vaccination': 'Fully Vaccinated',
      'aiAssessment': 'Low Risk',
      'statusColor': Colors.green,
      'date': '2024-06-01',
    },
    {
      'name': 'Maria Santos',
      'temperature': '37.9',
      'symptoms': 'Cough',
      'exposure': 'Contact with confirmed case',
      'vaccination': 'Partially Vaccinated',
      'aiAssessment': 'Further Review Needed',
      'statusColor': Colors.red,
      'date': '2024-06-01',
    },
    {
      'name': 'Alex Tan',
      'temperature': '36.5',
      'symptoms': 'None',
      'exposure': 'None',
      'vaccination': 'Not Provided',
      'aiAssessment': 'Low Risk',
      'statusColor': Colors.green,
      'date': '2024-06-01',
    },
  ];

  List<Map<String, dynamic>> get filteredDeclarations {
    return healthDeclarations.where((d) {
      return d['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          d['aiAssessment'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          d['symptoms'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          d['exposure'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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
          text: 'Health Surveillance & Disease Prevention',
          fontSize: 22,
          color: white,
          fontFamily: 'Bold',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(40),
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'AI-Powered Health Surveillance',
                    fontSize: 28,
                    color: primary,
                    fontFamily: 'Bold',
                    align: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  TextWidget(
                    text:
                        'Monitor tourist health declarations, AI screening, vaccination status, and contact tracing.',
                    fontSize: 16,
                    color: black,
                    fontFamily: 'Regular',
                    align: TextAlign.left,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Health Declarations',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    SizedBox(
                      width: isWide ? 350 : 220,
                      child: TextField(
                        controller: searchController,
                        onChanged: (val) => setState(() => searchQuery = val),
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          hintText: 'Search by name, symptoms, or risk',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Temp (°C)')),
                      DataColumn(label: Text('Symptoms')),
                      DataColumn(label: Text('Exposure')),
                      DataColumn(label: Text('Vaccination')),
                      DataColumn(label: Text('AI Assessment')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filteredDeclarations.map((d) {
                      return DataRow(cells: [
                        DataCell(Text(d['name'])),
                        DataCell(Text(d['date'])),
                        DataCell(Text(d['temperature'])),
                        DataCell(Text(d['symptoms'])),
                        DataCell(Text(d['exposure'])),
                        DataCell(Text(d['vaccination'])),
                        DataCell(Row(
                          children: [
                            Icon(Icons.circle,
                                color: d['statusColor'], size: 12),
                            const SizedBox(width: 6),
                            Text(d['aiAssessment'],
                                style: TextStyle(color: d['statusColor'])),
                          ],
                        )),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.blue),
                              onPressed: () {
                                _showDeclarationDetails(d);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.flag,
                                  color: Colors.redAccent),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: TextWidget(
                                      text:
                                          'Flagged for review. Authorities notified.',
                                      fontSize: 14,
                                      color: white,
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
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
                TextWidget(
                  text: 'Smart Contact Tracing & Health Alerts',
                  fontSize: 22,
                  color: black,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 12),
                TextWidget(
                  text:
                      'Uses geolocation tracking to identify potential exposure within tourist spots. If a health risk is detected, E-Lakbay notifies affected tourists and authorities while ensuring privacy compliance.',
                  fontSize: 14,
                  color: black,
                  fontFamily: 'Regular',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextWidget(
                            text:
                                'No health risks detected in tourist spots. All clear!',
                            fontSize: 15,
                            color: Colors.green,
                            fontFamily: 'Bold',
                            align: TextAlign.left,
                          ),
                        ),
                        ButtonWidget(
                          label: 'Send Health Alert',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: TextWidget(
                                  text:
                                      'Health alert sent to affected tourists and authorities.',
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
                          width: 180,
                          height: 40,
                          fontSize: 14,
                          radius: 8,
                        ),
                      ],
                    ),
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

  void _showDeclarationDetails(Map<String, dynamic> d) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Health Declaration Details',
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Name', d['name']),
              _buildDetailRow('Date', d['date']),
              _buildDetailRow('Temperature', d['temperature']),
              _buildDetailRow('Symptoms', d['symptoms']),
              _buildDetailRow('Exposure', d['exposure']),
              _buildDetailRow('Vaccination', d['vaccination']),
              _buildDetailRow('AI Assessment', d['aiAssessment']),
            ],
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: '$label: ',
            fontSize: 14,
            color: black,
            fontFamily: 'Medium',
          ),
          Expanded(
            child: TextWidget(
              text: value,
              fontSize: 14,
              color: grey,
              fontFamily: 'Regular',
              align: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
