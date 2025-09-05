import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/screens/local_businesses_admin_screen.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'package:autour_web/screens/disaster_preparedness_admin_screen.dart';
import 'package:autour_web/screens/community_engagement_admin_screen.dart';
import 'package:autour_web/screens/health_surveillance_admin_screen.dart';
import 'package:autour_web/screens/common_dialects_admin_screen.dart';
import 'package:autour_web/screens/travel_planner_admin_screen.dart';
import 'package:autour_web/widgets/analytics_graphs.dart';
// Added imports for PDF generation
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to generate and download PDF with user data
  Future<void> _downloadUsersPdf(BuildContext context) async {
    try {
      // Fetch users data from Firestore
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final users = usersSnapshot.docs;

      // Create PDF document
      final pdf = pw.Document();

      // Add page with user data
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AuTour Users Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Generated on: ${DateTime.now().toString()}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Total Users: ${users.length}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                // Add user data table
                pw.Table.fromTextArray(
                  headers: [
                    'Name',
                    'Email',
                    'Phone',
                    'Nationality',
                  ],
                  data: users.map((user) {
                    final data = user.data();
                    return [
                      data['fullName'] ?? 'N/A',
                      data['email'] ?? 'N/A',
                      data['mobile'] ?? 'N/A',
                      data['nationality'] ?? 'N/A',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: pw.TextStyle(fontSize: 10),
                  border: null,
                ),
              ],
            );
          },
        ),
      );

      // Generate PDF bytes
      final bytes = await pdf.save();

      // Create download link
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download =
            'autour_users_${DateTime.now().millisecondsSinceEpoch}.pdf';

      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Users PDF downloaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
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
        backgroundColor: primary,
        elevation: 2,
        foregroundColor: white,
        title: TextWidget(
          text: 'AuTour Admin Dashboard',
          fontSize: 22,
          color: white,
          fontFamily: 'Bold',
        ),
        // Add PDF download button to app bar
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
                    text: 'Welcome, Admin!',
                    fontSize: 32,
                    color: primary,
                    fontFamily: 'Bold',
                    align: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  TextWidget(
                    text:
                        'Manage and monitor AuTour features from this dashboard.',
                    fontSize: 18,
                    color: black,
                    fontFamily: 'Regular',
                    align: TextAlign.left,
                  ),
                  // Add PDF download button in the welcome section
                  const SizedBox(height: 20),
                  ButtonWidget(
                    label: 'Download Users PDF Report',
                    onPressed: () => _downloadUsersPdf(context),
                    color: primary,
                    textColor: white,
                    width: 250,
                    height: 45,
                    fontSize: 16,
                    radius: 10,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          // INSIGHTS & ANALYTICS SECTION
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Insights & Analytics',
                    fontSize: 22,
                    color: black,
                    fontFamily: 'Bold',
                    align: TextAlign.left,
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Expanded(child: TouristGrowthLineChart()),
                            SizedBox(width: 32),
                            Expanded(child: CheckinsBarChart()),
                            SizedBox(width: 32),
                            Expanded(child: NationalityPieChart()),
                          ],
                        );
                      } else {
                        return Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: const [
                            TouristGrowthLineChart(),
                            CheckinsBarChart(),
                            NationalityPieChart(),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      final cardWidth = isWide ? 320.0 : double.infinity;
                      return Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: TextWidget(
                                      text: 'Error loading merchants',
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontFamily: 'Medium',
                                    ),
                                  );
                                }
                                final docs = snapshot.data?.docs ?? const [];
                                return _buildAnalyticsCard(
                                  icon: Icons.account_circle,
                                  color: Colors.blue,
                                  title: 'Tourist Profile & Identification',
                                  description:
                                      'Personal, demographic, and emergency info. Consent records for geolocation and health tracking.',
                                  value: docs.length,
                                  valueLabel: 'Total Tourists',
                                );
                              }),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('scans')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: TextWidget(
                                      text: 'Error loading merchants',
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontFamily: 'Medium',
                                    ),
                                  );
                                }
                                final docs = snapshot.data?.docs ?? const [];
                                return _buildAnalyticsCard(
                                  icon: Icons.location_on,
                                  color: Colors.deepPurple,
                                  title: 'Geolocation & Travel Activity',
                                  description:
                                      'Real-time GPS logs, check-ins, and risk/emergency alerts.',
                                  value: docs.length,
                                  valueLabel: 'Check-ins',
                                );
                              }),
                          _buildAnalyticsCard(
                            icon: Icons.map,
                            color: Colors.green,
                            title: 'Smart Tourism Map & Metadata',
                            description:
                                'Attraction data, eco-site tags, hazard zones, and emergency services.',
                            value: 11,
                            valueLabel: 'Sites Mapped',
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('businesses')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: TextWidget(
                                      text: 'Error loading merchants',
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontFamily: 'Medium',
                                    ),
                                  );
                                }
                                final docs = snapshot.data?.docs ?? const [];
                                return _buildAnalyticsCard(
                                  icon: Icons.store_mall_directory,
                                  color: Colors.orange,
                                  title: 'Local Vendor & Business Integration',
                                  description:
                                      'Vendor profiles, services, pricing, and AI customer trend reports.',
                                  value: docs.length,
                                  valueLabel: 'Vendors',
                                );
                              }),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('ai_suggestions')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: TextWidget(
                                      text: 'Error loading merchants',
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontFamily: 'Medium',
                                    ),
                                  );
                                }
                                final docs = snapshot.data?.docs ?? const [];
                                return _buildAnalyticsCard(
                                  icon: Icons.warning,
                                  color: Colors.redAccent,
                                  title: 'Disaster & Weather Alert System',
                                  description:
                                      'Hazard alerts, severity, evacuation guides, and safety chatbot responses.',
                                  value: docs.length,
                                  valueLabel: 'Active Alerts',
                                );
                              }),
                          _buildAnalyticsCard(
                            icon: Icons.tour,
                            color: Colors.indigo,
                            title: 'Custom Travel Planning & AI',
                            description:
                                'Personalized itineraries, smart suggestions, and feedback learning.',
                            value: 13,
                            valueLabel: 'Itineraries',
                          ),
                          _buildAnalyticsCard(
                            icon: Icons.history_edu,
                            color: Colors.brown,
                            title: 'Community & Cultural Knowledge',
                            description:
                                'Stories, traditions, events, and verified digital storytelling.',
                            value: 3,
                            valueLabel: 'Stories',
                          ),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('scans')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: TextWidget(
                                      text: 'Error loading merchants',
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontFamily: 'Medium',
                                    ),
                                  );
                                }
                                final docs = snapshot.data?.docs ?? const [];
                                return _buildAnalyticsCard(
                                  icon: Icons.qr_code,
                                  color: Colors.cyan,
                                  title: 'QR Code & Access Control',
                                  description:
                                      'Visitor identity, access logs, emergency profile access, and offline sync.',
                                  value: docs.length,
                                  valueLabel: 'QR Scans',
                                );
                              }),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collectionGroup('health_declarations')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: TextWidget(
                                      text: 'Error loading merchants',
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontFamily: 'Medium',
                                    ),
                                  );
                                }
                                final docs = snapshot.data?.docs ?? const [];
                                return _buildAnalyticsCard(
                                  icon: Icons.health_and_safety,
                                  color: Colors.deepPurpleAccent,
                                  title:
                                      'Health Surveillance & Disease Prevention',
                                  description:
                                      'Health declarations, vaccination uploads, exposure and contact tracing.',
                                  value: docs.length,
                                  valueLabel: 'Health Declarations',
                                );
                              }),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                              stream: FirebaseFirestore.instance
                                  .collection('common_dialects')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: TextWidget(
                                      text: 'Error loading merchants',
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontFamily: 'Medium',
                                    ),
                                  );
                                }
                                final docs = snapshot.data?.docs ?? const [];
                                return _buildAnalyticsCard(
                                  icon: Icons.translate,
                                  color: Colors.amber,
                                  title: 'Crowdsourced Dialects & Language',
                                  description:
                                      'Dialect phrases, usage, town tags, and community verification.',
                                  value: docs.length,
                                  valueLabel: 'Dialect Entries',
                                );
                              }),
                        ]
                            .map((card) =>
                                SizedBox(width: cardWidth, child: card))
                            .toList(),
                      );
                    },
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
                TextWidget(
                  text: 'Admin Features',
                  fontSize: 22,
                  color: black,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 32,
                  runSpacing: 32,
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.store,
                      color: secondary,
                      title: 'Manage Local Businesses',
                      description:
                          'Marketplace for local businesses, accommodations, and services.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const LocalBusinessesAdminScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.warning_amber,
                      color: Colors.redAccent,
                      title: 'Disaster Preparedness & Weather Alerts',
                      description:
                          'Real-time weather, emergency warnings, and AI safety insights.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const DisasterPreparednessAdminScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.groups,
                      color: Colors.green,
                      title: 'Community Engagement & Cultural Preservation',
                      description:
                          'Share stories, heritage, and promote sustainable tourism.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CommunityEngagementAdminScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.health_and_safety,
                      color: Colors.deepPurple,
                      title: 'Health Surveillance & Disease Prevention',
                      description:
                          'AI-powered health declaration, screening, vaccination, and contact tracing.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const HealthSurveillanceAdminScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.language,
                      color: Colors.orange,
                      title: 'Common Dialects',
                      description:
                          'Manage and verify local dialects, phrases, and examples.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CommonDialectsAdminScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.tour,
                      color: Colors.indigo,
                      title: 'Travel Planner',
                      description:
                          'Manage destinations, activities, and travel tips for tourists.',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TravelPlannerAdminScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    int? value,
    String? valueLabel,
  }) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (value != null) ...[
                TextWidget(
                  text: value.toString(),
                  fontSize: 32,
                  color: color,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                if (valueLabel != null)
                  TextWidget(
                    text: valueLabel,
                    fontSize: 13,
                    color: color,
                    fontFamily: 'Regular',
                    align: TextAlign.left,
                  ),
                const SizedBox(height: 7),
              ],
              TextWidget(
                text: title,
                fontSize: 16,
                color: color,
                fontFamily: 'Bold',
                align: TextAlign.left,
              ),
              const SizedBox(height: 7),
              TextWidget(
                text: description,
                fontSize: 13,
                color: black,
                fontFamily: 'Regular',
                align: TextAlign.left,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required String description,
      required VoidCallback onTap}) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return SizedBox(
      width: isWide ? 340 : double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios, color: color, size: 20),
                  ],
                ),
                const SizedBox(height: 18),
                TextWidget(
                  text: title,
                  fontSize: 18,
                  color: color,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: description,
                  fontSize: 14,
                  color: black,
                  fontFamily: 'Regular',
                  align: TextAlign.left,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
