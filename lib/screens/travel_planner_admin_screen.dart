import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/textfield_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';

class TravelPlannerAdminScreen extends StatefulWidget {
  const TravelPlannerAdminScreen({super.key});

  @override
  State<TravelPlannerAdminScreen> createState() =>
      _TravelPlannerAdminScreenState();
}

class _TravelPlannerAdminScreenState extends State<TravelPlannerAdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for destinations
  final TextEditingController _destNameController = TextEditingController();
  final TextEditingController _destDescriptionController =
      TextEditingController();
  final TextEditingController _destMunicipalityController =
      TextEditingController();
  final TextEditingController _destLatitudeController = TextEditingController();
  final TextEditingController _destLongitudeController =
      TextEditingController();

  // Controllers for activities
  final TextEditingController _actTitleController = TextEditingController();
  final TextEditingController _actDescriptionController =
      TextEditingController();
  final TextEditingController _actLocationController = TextEditingController();
  final TextEditingController _actDurationController = TextEditingController();
  final TextEditingController _actCostController = TextEditingController();

  // Controllers for tips
  final TextEditingController _tipTitleController = TextEditingController();
  final TextEditingController _tipDescriptionController =
      TextEditingController();

  // Search controllers
  final TextEditingController _destSearchController = TextEditingController();
  final TextEditingController _actSearchController = TextEditingController();
  final TextEditingController _tipSearchController = TextEditingController();

  // Selected categories
  List<String> _selectedDestCategories = [];
  List<String> _selectedActCategories = [];
  List<String> _selectedTipCategories = [];

  // Predefined categories
  final List<String> _destinationCategories = [
    'Beaches',
    'Hiking',
    'Eco-Tourism',
    'Viewpoints',
    'Food',
    'Waterfalls',
    'Snorkeling',
    'Swimming',
    'Sunrise',
    'Peaceful',
    'History',
    'Culture',
    'Architecture',
    'Adventure',
    'Caving',
    'Nature',
    'Photography',
    'Local Businesses',
    'Walking',
    'Shopping'
  ];

  final List<String> _activityCategories = [
    'Surfing',
    'Lessons',
    'Water Sports',
    'Hiking',
    'Waterfalls',
    'Adventure',
    'Viewpoints',
    'Caving',
    'Snorkeling',
    'Nature',
    'Food',
    'Eco-Tourism',
    'Local Businesses',
    'History',
    'Culture',
    'Walking',
    'Photography',
    'Sunrise',
    'Shopping',
    'Transportation'
  ];

  final List<String> _tipCategories = [
    'Planning',
    'Weather',
    'Seasons',
    'Transportation',
    'Getting Around',
    'Mobility',
    'Safety',
    'Permits',
    'Guides',
    'Packing',
    'Essentials',
    'Preparation',
    'Culture',
    'Etiquette',
    'Respect',
    'Emergency',
    'Contacts',
    'Eco-Tourism',
    'Sustainability',
    'Environment',
    'Technology',
    'Connectivity',
    'Money',
    'Payments',
    'Finance',
    'Health',
    'Safety',
    'Preparation'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _destNameController.dispose();
    _destDescriptionController.dispose();
    _destMunicipalityController.dispose();
    _destLatitudeController.dispose();
    _destLongitudeController.dispose();
    _actTitleController.dispose();
    _actDescriptionController.dispose();
    _actLocationController.dispose();
    _actDurationController.dispose();
    _actCostController.dispose();
    _tipTitleController.dispose();
    _tipDescriptionController.dispose();
    _destSearchController.dispose();
    _actSearchController.dispose();
    _tipSearchController.dispose();
    super.dispose();
  }

  // DESTINATIONS METHODS
  Future<void> _addDestination() async {
    if (_destNameController.text.isEmpty ||
        _destDescriptionController.text.isEmpty ||
        _destMunicipalityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      await _firestore.collection('destinations').add({
        'name': _destNameController.text,
        'description': _destDescriptionController.text,
        'municipality': _destMunicipalityController.text,
        'categories': _selectedDestCategories,
        'latitude': double.tryParse(_destLatitudeController.text) ?? 0.0,
        'longitude': double.tryParse(_destLongitudeController.text) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _destNameController.clear();
      _destDescriptionController.clear();
      _destMunicipalityController.clear();
      _destLatitudeController.clear();
      _destLongitudeController.clear();
      setState(() {
        _selectedDestCategories.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding destination: $e')),
      );
    }
  }

  Future<void> _updateDestination(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('destinations').doc(id).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating destination: $e')),
      );
    }
  }

  Future<void> _deleteDestination(String id) async {
    try {
      await _firestore.collection('destinations').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destination deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting destination: $e')),
      );
    }
  }

  // ACTIVITIES METHODS
  Future<void> _addActivity() async {
    if (_actTitleController.text.isEmpty ||
        _actDescriptionController.text.isEmpty ||
        _actLocationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      await _firestore.collection('activities').add({
        'title': _actTitleController.text,
        'description': _actDescriptionController.text,
        'location': _actLocationController.text,
        'categories': _selectedActCategories,
        'duration': double.tryParse(_actDurationController.text) ?? 0.0,
        'cost': double.tryParse(_actCostController.text) ?? 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _actTitleController.clear();
      _actDescriptionController.clear();
      _actLocationController.clear();
      _actDurationController.clear();
      _actCostController.clear();
      setState(() {
        _selectedActCategories.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding activity: $e')),
      );
    }
  }

  Future<void> _updateActivity(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('activities').doc(id).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating activity: $e')),
      );
    }
  }

  Future<void> _deleteActivity(String id) async {
    try {
      await _firestore.collection('activities').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting activity: $e')),
      );
    }
  }

  // TIPS METHODS
  Future<void> _addTip() async {
    if (_tipTitleController.text.isEmpty ||
        _tipDescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      await _firestore.collection('tips').add({
        'title': _tipTitleController.text,
        'description': _tipDescriptionController.text,
        'categories': _selectedTipCategories,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear form
      _tipTitleController.clear();
      _tipDescriptionController.clear();
      setState(() {
        _selectedTipCategories.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tip added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding tip: $e')),
      );
    }
  }

  Future<void> _updateTip(String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('tips').doc(id).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tip updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating tip: $e')),
      );
    }
  }

  Future<void> _deleteTip(String id) async {
    try {
      await _firestore.collection('tips').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tip deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting tip: $e')),
      );
    }
  }

  // Category selection methods
  void _toggleDestinationCategory(String category) {
    setState(() {
      if (_selectedDestCategories.contains(category)) {
        _selectedDestCategories.remove(category);
      } else {
        _selectedDestCategories.add(category);
      }
    });
  }

  void _toggleActivityCategory(String category) {
    setState(() {
      if (_selectedActCategories.contains(category)) {
        _selectedActCategories.remove(category);
      } else {
        _selectedActCategories.add(category);
      }
    });
  }

  void _toggleTipCategory(String category) {
    setState(() {
      if (_selectedTipCategories.contains(category)) {
        _selectedTipCategories.remove(category);
      } else {
        _selectedTipCategories.add(category);
      }
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
          text: 'Travel Planner Content Management',
          fontSize: 22,
          color: white,
          fontFamily: 'Bold',
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: TextStyle(fontFamily: 'Bold', color: Colors.white),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Destinations'),
            Tab(text: 'Activities'),
            Tab(text: 'Travel Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Destinations Tab
          _buildDestinationsTab(isWide),
          // Activities Tab
          _buildActivitiesTab(isWide),
          // Travel Tips Tab
          _buildTipsTab(isWide),
        ],
      ),
    );
  }

  Widget _buildDestinationsTab(bool isWide) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('destinations').snapshots(),
      builder: (context, snapshot) {
        final destinations = snapshot.data?.docs ?? [];
        final filteredDestinations = destinations.where((destination) {
          final data = destination.data() as Map<String, dynamic>;
          final search = _destSearchController.text.toLowerCase();
          return data['name'].toString().toLowerCase().contains(search) ||
              data['municipality'].toString().toLowerCase().contains(search) ||
              (data['categories'] as List<dynamic>?)?.any((category) =>
                      category.toString().toLowerCase().contains(search)) ==
                  true;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(40),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Destinations Management',
                      fontSize: 28,
                      color: primary,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      text:
                          'Add, edit, or remove tourist destinations across Aurora Province',
                      fontSize: 16,
                      color: black,
                      fontFamily: 'Regular',
                      align: TextAlign.left,
                    ),
                    const SizedBox(height: 30),
                    // Summary cards
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildSummaryCard('Total Destinations',
                              destinations.length.toString(), primary),
                          _buildSummaryCard(
                              'Municipalities',
                              destinations
                                  .map((d) => (d.data()
                                      as Map<String, dynamic>)['municipality'])
                                  .toSet()
                                  .length
                                  .toString(),
                              secondary),
                          _buildSummaryCard(
                              'Categories',
                              _destinationCategories
                                  .where((category) => destinations.any((d) =>
                                      (d.data() as Map<String, dynamic>)[
                                              'categories']
                                          ?.contains(category) ==
                                      true))
                                  .length
                                  .toString(),
                              Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Search and Add button
                    Row(
                      children: [
                        Expanded(
                          child: _buildSearchField(
                            controller: _destSearchController,
                            hint:
                                'Search destinations by name, municipality, or category',
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ButtonWidget(
                          label: 'Add Destination',
                          onPressed: () {
                            // Simply show a message that the form is above
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Add form is located above')),
                            );
                          },
                          width: 180,
                          height: 50,
                          fontSize: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Add Destination Form
                    _buildAddDestinationForm(isWide),
                    const SizedBox(height: 40),
                    // Destinations List
                    _buildDestinationsList(isWide, filteredDestinations),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActivitiesTab(bool isWide) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('activities').snapshots(),
      builder: (context, snapshot) {
        final activities = snapshot.data?.docs ?? [];
        final filteredActivities = activities.where((activity) {
          final data = activity.data() as Map<String, dynamic>;
          final search = _actSearchController.text.toLowerCase();
          return data['title'].toString().toLowerCase().contains(search) ||
              data['location'].toString().toLowerCase().contains(search) ||
              (data['categories'] as List<dynamic>?)?.any((category) =>
                      category.toString().toLowerCase().contains(search)) ==
                  true;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(40),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Activities Management',
                      fontSize: 28,
                      color: primary,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      text:
                          'Create activities with titles, descriptions, and locations',
                      fontSize: 16,
                      color: black,
                      fontFamily: 'Regular',
                      align: TextAlign.left,
                    ),
                    const SizedBox(height: 30),
                    // Summary cards
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildSummaryCard('Total Activities',
                              activities.length.toString(), primary),
                          _buildSummaryCard(
                              'Locations',
                              activities
                                  .map((a) => (a.data()
                                      as Map<String, dynamic>)['location'])
                                  .toSet()
                                  .length
                                  .toString(),
                              secondary),
                          _buildSummaryCard(
                              'Avg. Duration',
                              activities.isNotEmpty
                                  ? (activities
                                              .map((a) =>
                                                  double.tryParse((a.data()
                                                              as Map<String,
                                                                  dynamic>)[
                                                          'duration']
                                                      .toString()) ??
                                                  0.0)
                                              .reduce((a, b) => a + b) /
                                          activities.length)
                                      .toStringAsFixed(1)
                                  : '0',
                              Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Search and Add button
                    Row(
                      children: [
                        Expanded(
                          child: _buildSearchField(
                            controller: _actSearchController,
                            hint:
                                'Search activities by title, location, or category',
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ButtonWidget(
                          label: 'Add Activity',
                          onPressed: () {
                            // Simply show a message that the form is above
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Add form is located above')),
                            );
                          },
                          width: 180,
                          height: 50,
                          fontSize: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Add Activity Form
                    _buildAddActivityForm(isWide),
                    const SizedBox(height: 40),
                    // Activities List
                    _buildActivitiesList(isWide, filteredActivities),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipsTab(bool isWide) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tips').snapshots(),
      builder: (context, snapshot) {
        final tips = snapshot.data?.docs ?? [];
        final filteredTips = tips.where((tip) {
          final data = tip.data() as Map<String, dynamic>;
          final search = _tipSearchController.text.toLowerCase();
          return data['title'].toString().toLowerCase().contains(search) ||
              (data['categories'] as List<dynamic>?)?.any((category) =>
                      category.toString().toLowerCase().contains(search)) ==
                  true;
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(40),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Travel Tips Management',
                      fontSize: 28,
                      color: primary,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const SizedBox(height: 10),
                    TextWidget(
                      text: 'Add practical tips for travelers',
                      fontSize: 16,
                      color: black,
                      fontFamily: 'Regular',
                      align: TextAlign.left,
                    ),
                    const SizedBox(height: 30),
                    // Summary cards
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildSummaryCard(
                              'Total Tips', tips.length.toString(), primary),
                          _buildSummaryCard(
                              'Categories',
                              _tipCategories
                                  .where((category) => tips.any((t) =>
                                      (t.data() as Map<String, dynamic>)[
                                              'categories']
                                          ?.contains(category) ==
                                      true))
                                  .length
                                  .toString(),
                              secondary),
                          _buildSummaryCard(
                              'Most Used Category',
                              tips.isNotEmpty
                                  ? _tipCategories
                                      .map((category) => MapEntry(
                                          category,
                                          tips
                                              .where((t) =>
                                                  (t.data() as Map<String,
                                                              dynamic>)[
                                                          'categories']
                                                      ?.contains(category) ==
                                                  true)
                                              .length))
                                      .reduce(
                                          (a, b) => a.value > b.value ? a : b)
                                      .key
                                  : 'None',
                              Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Search and Add button
                    Row(
                      children: [
                        Expanded(
                          child: _buildSearchField(
                            controller: _tipSearchController,
                            hint: 'Search tips by title or category',
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ButtonWidget(
                          label: 'Add Tip',
                          onPressed: () {
                            // Simply show a message that the form is above
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Add form is located above')),
                            );
                          },
                          width: 180,
                          height: 50,
                          fontSize: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Add Tip Form
                    _buildAddTipForm(isWide),
                    const SizedBox(height: 40),
                    // Tips List
                    _buildTipsList(isWide, filteredTips),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Form builders
  Widget _buildAddDestinationForm(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Add New Destination',
            fontSize: 22,
            color: black,
            fontFamily: 'Bold',
            align: TextAlign.left,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _destNameController,
                            label: 'Destination Name *',
                            hint: 'Enter destination name',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _destDescriptionController,
                            label: 'Description *',
                            hint: 'Enter detailed description',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _destMunicipalityController,
                            label: 'Municipality *',
                            hint: 'Enter municipality',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _destLatitudeController,
                            label: 'Latitude',
                            hint: 'Enter latitude',
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _destLongitudeController,
                            label: 'Longitude',
                            hint: 'Enter longitude',
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 16),
                          _buildCategorySelector(
                            title: 'Categories',
                            categories: _destinationCategories,
                            selectedCategories: _selectedDestCategories,
                            onToggle: _toggleDestinationCategory,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTextField(
                      controller: _destNameController,
                      label: 'Destination Name *',
                      hint: 'Enter destination name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _destDescriptionController,
                      label: 'Description *',
                      hint: 'Enter detailed description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _destMunicipalityController,
                      label: 'Municipality *',
                      hint: 'Enter municipality',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _destLatitudeController,
                      label: 'Latitude',
                      hint: 'Enter latitude',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _destLongitudeController,
                      label: 'Longitude',
                      hint: 'Enter longitude',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySelector(
                      title: 'Categories',
                      categories: _destinationCategories,
                      selectedCategories: _selectedDestCategories,
                      onToggle: _toggleDestinationCategory,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ButtonWidget(
              label: 'Add Destination',
              onPressed: _addDestination,
              width: 180,
              height: 50,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddActivityForm(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Add New Activity',
            fontSize: 22,
            color: black,
            fontFamily: 'Bold',
            align: TextAlign.left,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _actTitleController,
                            label: 'Activity Title *',
                            hint: 'Enter activity title',
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _actDescriptionController,
                            label: 'Description *',
                            hint: 'Enter detailed description',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _actLocationController,
                            label: 'Location *',
                            hint: 'Enter location/municipality',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _actDurationController,
                            label: 'Duration (hours)',
                            hint: 'Enter duration in hours',
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _actCostController,
                            label: 'Cost (PHP)',
                            hint: 'Enter cost in PHP',
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                          const SizedBox(height: 16),
                          _buildCategorySelector(
                            title: 'Categories',
                            categories: _activityCategories,
                            selectedCategories: _selectedActCategories,
                            onToggle: _toggleActivityCategory,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTextField(
                      controller: _actTitleController,
                      label: 'Activity Title *',
                      hint: 'Enter activity title',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _actDescriptionController,
                      label: 'Description *',
                      hint: 'Enter detailed description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _actLocationController,
                      label: 'Location *',
                      hint: 'Enter location/municipality',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _actDurationController,
                      label: 'Duration (hours)',
                      hint: 'Enter duration in hours',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _actCostController,
                      label: 'Cost (PHP)',
                      hint: 'Enter cost in PHP',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    _buildCategorySelector(
                      title: 'Categories',
                      categories: _activityCategories,
                      selectedCategories: _selectedActCategories,
                      onToggle: _toggleActivityCategory,
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ButtonWidget(
              label: 'Add Activity',
              onPressed: _addActivity,
              width: 180,
              height: 50,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTipForm(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: 'Add New Travel Tip',
            fontSize: 22,
            color: black,
            fontFamily: 'Bold',
            align: TextAlign.left,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _tipTitleController,
            label: 'Tip Title *',
            hint: 'Enter tip title',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _tipDescriptionController,
            label: 'Description *',
            hint: 'Enter detailed advice',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildCategorySelector(
            title: 'Categories',
            categories: _tipCategories,
            selectedCategories: _selectedTipCategories,
            onToggle: _toggleTipCategory,
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: ButtonWidget(
              label: 'Add Tip',
              onPressed: _addTip,
              width: 180,
              height: 50,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // List builders
  Widget _buildDestinationsList(
      bool isWide, List<QueryDocumentSnapshot<Object?>> destinations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Existing Destinations',
          fontSize: 22,
          color: black,
          fontFamily: 'Bold',
          align: TextAlign.left,
        ),
        const SizedBox(height: 20),
        if (destinations.isEmpty)
          const Center(
            child: Text('No destinations found'),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Municipality')),
                DataColumn(label: Text('Categories')),
                DataColumn(label: Text('Actions')),
              ],
              rows: destinations.map((destination) {
                final data = destination.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['name']?.toString() ?? '')),
                  DataCell(Text(data['municipality']?.toString() ?? '')),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        (data['categories'] as List<dynamic>?)?.join(', ') ??
                            '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditDestinationDialog(destination.id, data);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDeleteDestination(destination.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildActivitiesList(
      bool isWide, List<QueryDocumentSnapshot<Object?>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Existing Activities',
          fontSize: 22,
          color: black,
          fontFamily: 'Bold',
          align: TextAlign.left,
        ),
        const SizedBox(height: 20),
        if (activities.isEmpty)
          const Center(
            child: Text('No activities found'),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Duration')),
                DataColumn(label: Text('Cost')),
                DataColumn(label: Text('Actions')),
              ],
              rows: activities.map((activity) {
                final data = activity.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['title']?.toString() ?? '')),
                  DataCell(Text(data['location']?.toString() ?? '')),
                  DataCell(Text('${data['duration']?.toString() ?? ''} hrs')),
                  DataCell(Text('₱${data['cost']?.toString() ?? ''}')),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditActivityDialog(activity.id, data);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDeleteActivity(activity.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTipsList(
      bool isWide, List<QueryDocumentSnapshot<Object?>> tips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: 'Existing Travel Tips',
          fontSize: 22,
          color: black,
          fontFamily: 'Bold',
          align: TextAlign.left,
        ),
        const SizedBox(height: 20),
        if (tips.isEmpty)
          const Center(
            child: Text('No tips found'),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Categories')),
                DataColumn(label: Text('Actions')),
              ],
              rows: tips.map((tip) {
                final data = tip.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['title']?.toString() ?? '')),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        (data['categories'] as List<dynamic>?)?.join(', ') ??
                            '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showEditTipDialog(tip.id, data);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDeleteTip(tip.id);
                          },
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
      ],
    );
  }

  // Helper widgets
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFieldWidget(
      label: label,
      hint: hint,
      controller: controller,
      maxLine: maxLines,
      inputType: keyboardType,
      width: double.infinity,
      height: maxLines > 1 ? 120 : 65,
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildCategorySelector({
    required String title,
    required List<String> categories,
    required List<String> selectedCategories,
    required Function(String) onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                onToggle(category);
              },
              selectedColor: primary,
              backgroundColor: Colors.grey[200],
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        if (selectedCategories.isNotEmpty)
          Text('Selected: ${selectedCategories.join(', ')}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
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

  // Dialog methods
  void _showEditDestinationDialog(String id, Map<String, dynamic> data) {
    final nameController =
        TextEditingController(text: data['name']?.toString() ?? '');
    final descriptionController =
        TextEditingController(text: data['description']?.toString() ?? '');
    final municipalityController =
        TextEditingController(text: data['municipality']?.toString() ?? '');
    final latitudeController =
        TextEditingController(text: data['latitude']?.toString() ?? '');
    final longitudeController =
        TextEditingController(text: data['longitude']?.toString() ?? '');
    final selectedCategories =
        List<String>.from(data['categories'] as List<dynamic>? ?? []);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          void toggleCategory(String category) {
            setState(() {
              if (selectedCategories.contains(category)) {
                selectedCategories.remove(category);
              } else {
                selectedCategories.add(category);
              }
            });
          }

          return AlertDialog(
            title: const Text('Edit Destination'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(
                    label: 'Name *',
                    hint: 'Enter destination name',
                    controller: nameController,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Description *',
                    hint: 'Enter detailed description',
                    controller: descriptionController,
                    maxLine: 3,
                    width: double.infinity,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Municipality *',
                    hint: 'Enter municipality',
                    controller: municipalityController,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Latitude',
                    hint: 'Enter latitude',
                    controller: latitudeController,
                    inputType: TextInputType.numberWithOptions(decimal: true),
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Longitude',
                    hint: 'Enter longitude',
                    controller: longitudeController,
                    inputType: TextInputType.numberWithOptions(decimal: true),
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  _buildCategorySelector(
                    title: 'Categories',
                    categories: _destinationCategories,
                    selectedCategories: selectedCategories,
                    onToggle: toggleCategory,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ButtonWidget(
                label: 'Save',
                onPressed: () {
                  if (nameController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      municipalityController.text.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all required fields')),
                    );
                    return;
                  }

                  _updateDestination(id, {
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'municipality': municipalityController.text,
                    'latitude': double.tryParse(latitudeController.text) ?? 0.0,
                    'longitude':
                        double.tryParse(longitudeController.text) ?? 0.0,
                    'categories': selectedCategories,
                  });

                  Navigator.pop(dialogContext);
                },
                width: 100,
                height: 40,
                fontSize: 14,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditActivityDialog(String id, Map<String, dynamic> data) {
    final titleController =
        TextEditingController(text: data['title']?.toString() ?? '');
    final descriptionController =
        TextEditingController(text: data['description']?.toString() ?? '');
    final locationController =
        TextEditingController(text: data['location']?.toString() ?? '');
    final durationController =
        TextEditingController(text: data['duration']?.toString() ?? '');
    final costController =
        TextEditingController(text: data['cost']?.toString() ?? '');
    final selectedCategories =
        List<String>.from(data['categories'] as List<dynamic>? ?? []);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          void toggleCategory(String category) {
            setState(() {
              if (selectedCategories.contains(category)) {
                selectedCategories.remove(category);
              } else {
                selectedCategories.add(category);
              }
            });
          }

          return AlertDialog(
            title: const Text('Edit Activity'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(
                    label: 'Title *',
                    hint: 'Enter activity title',
                    controller: titleController,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Description *',
                    hint: 'Enter detailed description',
                    controller: descriptionController,
                    maxLine: 3,
                    width: double.infinity,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Location *',
                    hint: 'Enter location/municipality',
                    controller: locationController,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Duration (hours)',
                    hint: 'Enter duration in hours',
                    controller: durationController,
                    inputType: TextInputType.numberWithOptions(decimal: true),
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Cost (PHP)',
                    hint: 'Enter cost in PHP',
                    controller: costController,
                    inputType: TextInputType.numberWithOptions(decimal: true),
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  _buildCategorySelector(
                    title: 'Categories',
                    categories: _activityCategories,
                    selectedCategories: selectedCategories,
                    onToggle: toggleCategory,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ButtonWidget(
                label: 'Save',
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      locationController.text.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all required fields')),
                    );
                    return;
                  }

                  _updateActivity(id, {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'location': locationController.text,
                    'duration': double.tryParse(durationController.text) ?? 0.0,
                    'cost': double.tryParse(costController.text) ?? 0.0,
                    'categories': selectedCategories,
                  });

                  Navigator.pop(dialogContext);
                },
                width: 100,
                height: 40,
                fontSize: 14,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditTipDialog(String id, Map<String, dynamic> data) {
    final titleController =
        TextEditingController(text: data['title']?.toString() ?? '');
    final descriptionController =
        TextEditingController(text: data['description']?.toString() ?? '');
    final selectedCategories =
        List<String>.from(data['categories'] as List<dynamic>? ?? []);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          void toggleCategory(String category) {
            setState(() {
              if (selectedCategories.contains(category)) {
                selectedCategories.remove(category);
              } else {
                selectedCategories.add(category);
              }
            });
          }

          return AlertDialog(
            title: const Text('Edit Tip'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFieldWidget(
                    label: 'Title *',
                    hint: 'Enter tip title',
                    controller: titleController,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                  TextFieldWidget(
                    label: 'Description *',
                    hint: 'Enter detailed advice',
                    controller: descriptionController,
                    maxLine: 4,
                    width: double.infinity,
                    height: 150,
                  ),
                  const SizedBox(height: 16),
                  _buildCategorySelector(
                    title: 'Categories',
                    categories: _tipCategories,
                    selectedCategories: selectedCategories,
                    onToggle: toggleCategory,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ButtonWidget(
                label: 'Save',
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill all required fields')),
                    );
                    return;
                  }

                  _updateTip(id, {
                    'title': titleController.text,
                    'description': descriptionController.text,
                    'categories': selectedCategories,
                  });

                  Navigator.pop(dialogContext);
                },
                width: 100,
                height: 40,
                fontSize: 14,
              ),
            ],
          );
        },
      ),
    );
  }

  // Confirmation dialogs
  void _confirmDeleteDestination(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Destination'),
        content: const Text(
            'Are you sure you want to delete this destination? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ButtonWidget(
            label: 'Delete',
            onPressed: () {
              _deleteDestination(id);
              Navigator.pop(dialogContext);
            },
            color: Colors.red,
            width: 100,
            height: 40,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  void _confirmDeleteActivity(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Activity'),
        content: const Text(
            'Are you sure you want to delete this activity? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ButtonWidget(
            label: 'Delete',
            onPressed: () {
              _deleteActivity(id);
              Navigator.pop(dialogContext);
            },
            color: Colors.red,
            width: 100,
            height: 40,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

  void _confirmDeleteTip(String id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Tip'),
        content: const Text(
            'Are you sure you want to delete this tip? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ButtonWidget(
            label: 'Delete',
            onPressed: () {
              _deleteTip(id);
              Navigator.pop(dialogContext);
            },
            color: Colors.red,
            width: 100,
            height: 40,
            fontSize: 14,
          ),
        ],
      ),
    );
  }
}
