import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';

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

  // Firestore wiring
  static const String collectionName =
      'health_declarations'; // TODO: update if mobile uses a different collection
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final Query<Map<String, dynamic>> declarationsQuery =
      _db.collectionGroup(collectionName);

  // Live data from Firestore
  List<Map<String, dynamic>> declarations = [];

  List<Map<String, dynamic>> get filteredDeclarations {
    return declarations.where((d) {
      final q = searchQuery.toLowerCase();
      final name = (d['name'] ?? '').toString().toLowerCase();
      final symptoms = (d['symptoms'] ?? '').toString().toLowerCase();
      final exposure = (d['exposure'] ?? '').toString().toLowerCase();
      final vaccination = (d['vaccination'] ?? '').toString().toLowerCase();
      return name.contains(q) ||
          symptoms.contains(q) ||
          exposure.contains(q) ||
          vaccination.contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _setupFirestoreListener();
  }

  void _setupFirestoreListener() {
    declarationsQuery
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        declarations = s.docs.map((d) {
          final data = d.data();
          final String userId = (data['userId'] ?? '').toString();
          String name = (data['name'] ?? data['fullName'] ?? '').toString();
          if (name.isEmpty && userId.isNotEmpty) {
            name = userId;
          }
          String temperature =
              (data['temperature'] ?? data['temp'] ?? '-').toString();
          String symptoms;
          final rawSymptoms = data['symptoms'];
          if (rawSymptoms is List) {
            symptoms = rawSymptoms.map((e) => e.toString()).join(', ');
          } else {
            symptoms = (rawSymptoms ?? 'None').toString();
          }
          String exposure =
              (data['exposure'] ?? data['exposureStatus'] ?? 'None').toString();
          String vaccination = (data['vaccination'] ??
                  data['vaccinationStatus'] ??
                  'Not Provided')
              .toString();
          String dateStr = '-';
          final createdAt =
              data['createdAt'] ?? data['submittedAt'] ?? data['date'];
          if (createdAt is Timestamp) {
            dateStr = createdAt.toDate().toIso8601String().split('T').first;
          } else if (createdAt != null) {
            dateStr = createdAt.toString();
          }

          return {
            'name': name,
            'userId': userId,
            'temperature': temperature,
            'symptoms': symptoms,
            'exposure': exposure,
            'vaccination': vaccination,
            'date': dateStr,
          };
        }).toList();
      });
    });
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
                          hintText:
                              'Search by name, symptoms, exposure, or vaccination',
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
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.blue),
                              onPressed: () {
                                _showDeclarationDetails(d);
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
