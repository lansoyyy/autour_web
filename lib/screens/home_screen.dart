import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/screens/local_businesses_admin_screen.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'package:autour_web/screens/disaster_preparedness_admin_screen.dart';
import 'package:autour_web/screens/community_engagement_admin_screen.dart';
import 'package:autour_web/screens/health_surveillance_admin_screen.dart';
import 'package:autour_web/screens/common_dialects_admin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
