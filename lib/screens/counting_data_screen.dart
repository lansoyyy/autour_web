import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'package:autour_web/widgets/date_picker_widget.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

class CountingDataScreen extends StatefulWidget {
  const CountingDataScreen({super.key});

  @override
  State<CountingDataScreen> createState() => _CountingDataScreenState();
}

class _CountingDataScreenState extends State<CountingDataScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  bool _isLoading = false;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isExporting = false;

  Future<void> _addCountingData() async {
    if (_locationController.text.isEmpty || _countController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('counting').add({
        'timestamp': FieldValue.serverTimestamp(),
        'location': _locationController.text,
        'personCount': int.tryParse(_countController.text) ?? 0,
      });

      _locationController.clear();
      _countController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteCountingData(String docId) async {
    try {
      await _firestore.collection('counting').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _exportToPdf() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end dates'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      // Get filtered data
      QuerySnapshot querySnapshot;
      if (_startDate != null && _endDate != null) {
        // Adjust end date to include the entire day
        final adjustedEndDate = DateTime(
            _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        querySnapshot = await _firestore
            .collection('counting')
            .where('timestamp', isGreaterThanOrEqualTo: _startDate)
            .where('timestamp', isLessThanOrEqualTo: adjustedEndDate)
            .orderBy('timestamp', descending: true)
            .get();
      } else {
        querySnapshot = await _firestore
            .collection('counting')
            .orderBy('timestamp', descending: true)
            .get();
      }

      final docs = querySnapshot.docs;

      // Create PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'People Counting Data Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Date Range: ${DateFormat('yyyy-MM-dd').format(_startDate!)} to ${DateFormat('yyyy-MM-dd').format(_endDate!)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey,
                  ),
                ),
                pw.Text(
                  'Generated on: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Location', 'Person Count', 'Date & Time'],
                  data: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final timestamp = data['timestamp'] as Timestamp?;
                    final location = data['location'] as String? ?? 'Unknown';
                    final personCount = data['personCount'] as int? ?? 0;

                    return [
                      location,
                      personCount.toString(),
                      timestamp != null
                          ? DateFormat('yyyy-MM-dd HH:mm:ss')
                              .format(timestamp.toDate())
                          : 'No timestamp',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellAlignment: pw.Alignment.centerLeft,
                  border: pw.TableBorder.all(),
                ),
              ],
            );
          },
        ),
      );

      // Save PDF
      final bytes = await pdf.save();

      // Create download link
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download =
            'counting_data_${DateFormat('yyyyMMdd').format(_startDate!)}_to_${DateFormat('yyyyMMdd').format(_endDate!)}.pdf';

      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF exported successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Query _getQuery() {
    Query query = _firestore.collection('counting');

    if (_startDate != null && _endDate != null) {
      // Adjust end date to include the entire day
      final adjustedEndDate =
          DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
      query = query
          .where('timestamp', isGreaterThanOrEqualTo: _startDate)
          .where('timestamp', isLessThanOrEqualTo: adjustedEndDate);
    }

    return query.orderBy('timestamp', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 2,
        foregroundColor: white,
        title: TextWidget(
          text: 'People Counting Data',
          fontSize: 22,
          color: white,
          fontFamily: 'Bold',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Add New Counting Data',
                        fontSize: 20,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _countController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Person Count',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: primary, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addCountingData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Add Data'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextWidget(
                            text: 'Date Filter',
                            fontSize: 20,
                            color: primary,
                            fontFamily: 'Bold',
                          ),
                          ButtonWidget(
                            label:
                                _isExporting ? 'Exporting...' : 'Export to PDF',
                            onPressed: _isExporting
                                ? () {}
                                : () async {
                                    await _exportToPdf();
                                  },
                            color: primary,
                            textColor: white,
                            width: 150,
                            height: 40,
                            fontSize: 16,
                            radius: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                text: _startDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(_startDate!)
                                    : '',
                              ),
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: primary, width: 2),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: _startDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _startDate = picked;
                                      });
                                    }
                                  },
                                ),
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                text: _endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                    : '',
                              ),
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: primary, width: 2),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: _endDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _endDate = picked;
                                      });
                                    }
                                  },
                                ),
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ButtonWidget(
                            label: 'Clear Filter',
                            onPressed: () {
                              setState(() {
                                _startDate = null;
                                _endDate = null;
                              });
                            },
                            color: Colors.grey,
                            textColor: white,
                            width: 120,
                            height: 40,
                            fontSize: 16,
                            radius: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 500,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Counting Records',
                          fontSize: 20,
                          color: primary,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _getQuery().snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(
                                  child: TextWidget(
                                    text:
                                        'Error loading data: ${snapshot.error}',
                                    fontSize: 16,
                                    color: Colors.red,
                                    fontFamily: 'Medium',
                                  ),
                                );
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: TextWidget(
                                    text: 'No counting data available',
                                    fontSize: 16,
                                    color: Colors.grey,
                                    fontFamily: 'Medium',
                                  ),
                                );
                              }

                              final docs = snapshot.data!.docs;

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(
                                      label: Text('Location'),
                                    ),
                                    DataColumn(
                                      label: Text('Person Count'),
                                    ),
                                    DataColumn(
                                      label: Text('Date & Time'),
                                    ),
                                    DataColumn(
                                      label: Text('Actions'),
                                    ),
                                  ],
                                  rows: docs.map((doc) {
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final timestamp =
                                        data['timestamp'] as Timestamp?;
                                    final location =
                                        data['location'] as String? ??
                                            'Unknown';
                                    final personCount =
                                        data['personCount'] as int? ?? 0;

                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          TextWidget(
                                            text: location,
                                            fontSize: 14,
                                            color: black,
                                            fontFamily: 'Regular',
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: primary.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: TextWidget(
                                              text: '$personCount',
                                              fontSize: 14,
                                              color: primary,
                                              fontFamily: 'Medium',
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          TextWidget(
                                            text: timestamp != null
                                                ? DateFormat(
                                                        'yyyy-MM-dd HH:mm:ss')
                                                    .format(timestamp.toDate())
                                                : 'No timestamp',
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontFamily: 'Regular',
                                          ),
                                        ),
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _deleteCountingData(doc.id),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
