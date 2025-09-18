import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'dart:html' as html;
import 'dart:convert';

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

  // Evaluate health declaration and generate alert
  Map<String, dynamic> evaluateHealthDeclaration(
      Map<String, dynamic> declaration) {
    final temperature = declaration['temperature']?.toString() ?? '';
    final symptoms = declaration['symptoms']?.toString() ?? '';
    final exposure = declaration['exposure']?.toString() ?? '';
    final vaccination = declaration['vaccination']?.toString() ?? '';

    String alertLevel = 'Low';
    String alertMessage = 'No immediate health concerns identified.';
    String recommendation = 'Continue monitoring general health.';
    Color alertColor = Colors.green;

    // Check for high temperature
    double tempValue = 0;
    if (temperature.isNotEmpty && temperature != '-') {
      try {
        tempValue =
            double.parse(temperature.replaceAll(RegExp(r'[^0-9.]'), ''));
      } catch (e) {
        // Handle parsing error
      }
    }

    // High-risk conditions
    bool hasHighTemp = tempValue >= 38.0;
    bool hasSevereSymptoms = symptoms.toLowerCase().contains('fever') ||
        symptoms.toLowerCase().contains('cough') ||
        symptoms.toLowerCase().contains('difficulty breathing') ||
        symptoms.toLowerCase().contains('shortness of breath');
    bool hasExposure = exposure.toLowerCase().contains('yes') ||
        exposure.toLowerCase().contains('positive') ||
        exposure.toLowerCase().contains('contact');

    // Determine alert level
    if (hasHighTemp && hasSevereSymptoms) {
      alertLevel = 'Critical';
      alertMessage =
          'High temperature with severe symptoms detected. Immediate medical attention recommended.';
      recommendation =
          '1. Seek immediate medical attention\n2. Isolate the individual\n3. Contact health authorities\n4. Monitor vital signs continuously';
      alertColor = Colors.red;
    } else if (hasHighTemp || hasSevereSymptoms || hasExposure) {
      alertLevel = 'High';
      alertMessage =
          'Potential health risk identified. Medical consultation recommended.';
      recommendation =
          '1. Consult a healthcare provider\n2. Monitor symptoms closely\n3. Maintain isolation if exposure is suspected\n4. Stay hydrated and rest';
      alertColor = Colors.orange;
    } else if (tempValue >= 37.5 ||
        symptoms.toLowerCase().contains('mild') ||
        vaccination.toLowerCase().contains('not')) {
      alertLevel = 'Medium';
      alertMessage = 'Moderate health concern. Monitoring recommended.';
      recommendation =
          '1. Monitor symptoms daily\n2. Maintain good hygiene practices\n3. Consider vaccination if not up to date\n4. Rest and stay hydrated';
      alertColor = Colors.yellow;
    }

    return {
      'alertLevel': alertLevel,
      'alertMessage': alertMessage,
      'recommendation': recommendation,
      'alertColor': alertColor,
    };
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

          // Check if the declaration is archived
          final bool isArchived = data['isArchived'] ?? false;
          String archivedDateStr = '';
          if (isArchived) {
            final archivedAt = data['archivedAt'];
            if (archivedAt is Timestamp) {
              archivedDateStr =
                  archivedAt.toDate().toIso8601String().split('T').first;
            }
          }

          return {
            'id': d.id, // Add document ID for archiving
            'name': name,
            'userId': userId,
            'temperature': temperature,
            'symptoms': symptoms,
            'exposure': exposure,
            'vaccination': vaccination,
            'date': dateStr,
            'isArchived': isArchived,
            'archivedDate': archivedDateStr,
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
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _exportToCSV,
                          icon: const Icon(Icons.download),
                          label: const Text('Export CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondary,
                            foregroundColor: black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: isWide ? 350 : 220,
                          child: TextField(
                            controller: searchController,
                            onChanged: (val) =>
                                setState(() => searchQuery = val),
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
                  ],
                ),
                const SizedBox(height: 24),
                // Summary cards for health statistics
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildSummaryCard('Total Declarations',
                          filteredDeclarations.length.toString(), Colors.blue),
                      _buildSummaryCard('Critical Alerts',
                          _getAlertCount('Critical'), Colors.red),
                      _buildSummaryCard(
                          'High Alerts', _getAlertCount('High'), Colors.orange),
                      _buildSummaryCard('Medium Alerts',
                          _getAlertCount('Medium'), Colors.yellow),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Alert')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Temp (°C)')),
                      DataColumn(label: Text('Symptoms')),
                      DataColumn(label: Text('Exposure')),
                      DataColumn(label: Text('Vaccination')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filteredDeclarations.map((d) {
                      final evaluation = evaluateHealthDeclaration(d);
                      return DataRow(cells: [
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: evaluation['alertColor'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  evaluation['alertLevel'] == 'Critical'
                                      ? Icons.error
                                      : evaluation['alertLevel'] == 'High'
                                          ? Icons.warning
                                          : evaluation['alertLevel'] == 'Medium'
                                              ? Icons.info
                                              : Icons.check_circle,
                                  color: evaluation['alertColor'],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  evaluation['alertLevel'],
                                  style: TextStyle(
                                    color: evaluation['alertColor'],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(Text(d['name'])),
                        DataCell(Text(d['date'])),
                        DataCell(Text(d['temperature'])),
                        DataCell(Text(d['symptoms'])),
                        DataCell(Text(d['exposure'])),
                        DataCell(Text(d['vaccination'])),
                        DataCell(
                          d['isArchived'] == true
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.archive,
                                        color: Colors.orange, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Archived',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility,
                                  color: Colors.blue),
                              onPressed: () {
                                _showDeclarationDetails(d);
                              },
                            ),
                            if (d['isArchived'] != true)
                              IconButton(
                                icon: const Icon(Icons.archive,
                                    color: Colors.orange),
                                onPressed: () {
                                  _archiveDeclaration(d['id']);
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
    final evaluation = evaluateHealthDeclaration(d);

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
              _buildDetailRow(
                  'Status', d['isArchived'] == true ? 'Archived' : 'Active'),
              if (d['isArchived'] == true && d['archivedDate'].isNotEmpty)
                _buildDetailRow('Archived Date', d['archivedDate']),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: evaluation['alertColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: evaluation['alertColor']),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          evaluation['alertLevel'] == 'Critical'
                              ? Icons.error
                              : evaluation['alertLevel'] == 'High'
                                  ? Icons.warning
                                  : evaluation['alertLevel'] == 'Medium'
                                      ? Icons.info
                                      : Icons.check_circle,
                          color: evaluation['alertColor'],
                        ),
                        const SizedBox(width: 8),
                        TextWidget(
                          text: '${evaluation['alertLevel']} Risk Alert',
                          fontSize: 16,
                          color: evaluation['alertColor'],
                          fontFamily: 'Bold',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: evaluation['alertMessage'],
                      fontSize: 14,
                      color: black,
                      fontFamily: 'Regular',
                    ),
                    const SizedBox(height: 8),
                    TextWidget(
                      text: 'Recommended Actions:',
                      fontSize: 14,
                      color: black,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(height: 4),
                    TextWidget(
                      text: evaluation['recommendation'],
                      fontSize: 12,
                      color: grey,
                      fontFamily: 'Regular',
                    ),
                  ],
                ),
              ),
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

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            text: title,
            fontSize: 14,
            color: grey,
            fontFamily: 'Regular',
          ),
          const SizedBox(height: 8),
          TextWidget(
            text: value,
            fontSize: 24,
            color: color,
            fontFamily: 'Bold',
          ),
        ],
      ),
    );
  }

  String _getAlertCount(String alertLevel) {
    int count = 0;
    for (var declaration in filteredDeclarations) {
      final evaluation = evaluateHealthDeclaration(declaration);
      if (evaluation['alertLevel'] == alertLevel) {
        count++;
      }
    }
    return count.toString();
  }

  // Add a new health declaration
  void _addDeclaration() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final temperatureController = TextEditingController();
    final symptomsController = TextEditingController();
    final exposureController = TextEditingController();
    final vaccinationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Declaration'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Name is required' : null,
              ),
              TextFormField(
                controller: temperatureController,
                decoration:
                    const InputDecoration(labelText: 'Temperature (°C)'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextFormField(
                controller: symptomsController,
                decoration: const InputDecoration(labelText: 'Symptoms'),
              ),
              TextFormField(
                controller: exposureController,
                decoration: const InputDecoration(labelText: 'Exposure'),
              ),
              TextFormField(
                controller: vaccinationController,
                decoration: const InputDecoration(labelText: 'Vaccination'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() == true) {
                try {
                  await _db.collection(collectionName).add({
                    'name': nameController.text,
                    'temperature': temperatureController.text,
                    'symptoms': symptomsController.text,
                    'exposure': exposureController.text,
                    'vaccination': vaccinationController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Declaration added successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding declaration: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Archive a health declaration
  void _archiveDeclaration(String documentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Declaration'),
        content: const Text(
            'Are you sure you want to archive this declaration? It will still be viewable in the table.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Find the document in the declarations list
                final declaration = declarations.firstWhere(
                  (d) => d['id'] == documentId,
                  orElse: () => <String, Object>{},
                );

                if (declaration.isNotEmpty) {
                  // Try to get the document reference from the collection group
                  // We need to find the actual document path
                  final querySnapshot = await _db
                      .collectionGroup(collectionName)
                      .where('name', isEqualTo: declaration['name'])
                      .where('temperature',
                          isEqualTo: declaration['temperature'])
                      .limit(1)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    // Update the document to mark it as archived instead of deleting it
                    await querySnapshot.docs.first.reference.update({
                      'isArchived': true,
                      'archivedAt': FieldValue.serverTimestamp(),
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Declaration archived successfully')),
                    );
                  } else {
                    throw Exception('Document not found');
                  }
                } else {
                  throw Exception('Declaration not found in local list');
                }
              } catch (e) {
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error archiving declaration: $e')),
                );
              }
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  // Export data to CSV
  void _exportToCSV() {
    final csvData = <List<String>>[
      [
        'Name',
        'Date',
        'Temperature',
        'Symptoms',
        'Exposure',
        'Vaccination',
        'Status',
        'Archived Date'
      ],
    ];

    for (var declaration in filteredDeclarations) {
      csvData.add([
        declaration['name']?.toString() ?? '',
        declaration['date']?.toString() ?? '',
        declaration['temperature']?.toString() ?? '',
        declaration['symptoms']?.toString() ?? '',
        declaration['exposure']?.toString() ?? '',
        declaration['vaccination']?.toString() ?? '',
        declaration['isArchived'] == true ? 'Archived' : 'Active',
        declaration['archivedDate']?.toString() ?? '',
      ]);
    }

    // Convert to CSV string
    final csvString = csvData.map((row) => row.join(',')).join('\n');

    // Create and download CSV file
    final blob = html.Blob([csvString], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'health_declarations.csv')
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data exported to CSV successfully')),
    );
  }
}
