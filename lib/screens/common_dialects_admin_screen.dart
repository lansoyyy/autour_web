import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';

class CommonDialectsAdminScreen extends StatefulWidget {
  const CommonDialectsAdminScreen({super.key});

  @override
  State<CommonDialectsAdminScreen> createState() =>
      _CommonDialectsAdminScreenState();
}

class _CommonDialectsAdminScreenState extends State<CommonDialectsAdminScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedTown = 'All';
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference dialectsRef =
      _db.collection('common_dialects');
  List<String> _dialectIds = [];

  final List<String> towns = [
    'All',
    'Baler',
    'Dingalan',
    'Maria Aurora',
    'San Luis',
  ];

  List<Map<String, dynamic>> dialectEntries = [];

  @override
  void initState() {
    super.initState();
    _setupFirestoreListener();
  }

  void _setupFirestoreListener() {
    dialectsRef.orderBy('createdAt', descending: true).snapshots().listen((s) {
      setState(() {
        dialectEntries = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'phrase': (data['phrase'] ?? '').toString(),
            'meaning': (data['meaning'] ?? '').toString(),
            'pronunciation': (data['pronunciation'] ?? '').toString(),
            'town': (data['town'] ?? '').toString(),
            'language': (data['language'] ?? '').toString(),
            'usage': (data['usage'] ?? '').toString(),
            'example': (data['example'] ?? '').toString(),
            'verified': (data['verified'] ?? false) == true,
          };
        }).toList();
        _dialectIds = s.docs.map((d) => d.id).toList();
      });
    });
  }

  Future<void> _addDialect(Map<String, dynamic> data) async {
    await dialectsRef.add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> _updateDialect(int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _dialectIds.length) return;
    await dialectsRef.doc(_dialectIds[index]).update(data);
  }

  Future<void> _deleteDialectAt(int index) async {
    if (index < 0 || index >= _dialectIds.length) return;
    await dialectsRef.doc(_dialectIds[index]).delete();
  }

  List<Map<String, dynamic>> get filteredDialects {
    return dialectEntries.where((entry) {
      final matchesTown =
          selectedTown == 'All' || entry['town'] == selectedTown;
      final matchesSearch = entry['phrase']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          entry['meaning']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          entry['pronunciation']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          entry['usage']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          entry['example']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
      return matchesTown && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showDialectDialog({Map<String, dynamic>? entry, int? index}) {
    final phraseController =
        TextEditingController(text: entry?['phrase'] ?? '');
    final meaningController =
        TextEditingController(text: entry?['meaning'] ?? '');
    final pronunciationController =
        TextEditingController(text: entry?['pronunciation'] ?? '');
    String town = entry?['town'] ?? towns[1];
    final languageController =
        TextEditingController(text: entry?['language'] ?? '');
    final usageController = TextEditingController(text: entry?['usage'] ?? '');
    final exampleController =
        TextEditingController(text: entry?['example'] ?? '');
    bool verified = entry?['verified'] ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: entry == null ? 'Add Dialect Entry' : 'Edit Dialect Entry',
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField('Phrase', phraseController),
                _buildTextField('Meaning', meaningController),
                _buildTextField('Pronunciation', pronunciationController),
                DropdownButtonFormField<String>(
                  value: town,
                  items: towns
                      .where((t) => t != 'All')
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => town = val!,
                  decoration: const InputDecoration(labelText: 'Town'),
                ),
                _buildTextField('Language', languageController),
                _buildTextField('Usage Context', usageController),
                _buildTextField('Example', exampleController),
                Row(
                  children: [
                    Checkbox(
                      value: verified,
                      onChanged: (val) =>
                          setState(() => verified = val ?? false),
                    ),
                    const SizedBox(width: 4),
                    const Text('Verified by Community'),
                  ],
                ),
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
                fontFamily: 'Regular'),
          ),
          ButtonWidget(
            label: entry == null ? 'Add' : 'Save',
            onPressed: () async {
              final newEntry = {
                'phrase': phraseController.text,
                'meaning': meaningController.text,
                'pronunciation': pronunciationController.text,
                'town': town,
                'language': languageController.text,
                'usage': usageController.text,
                'example': exampleController.text,
                'verified': verified,
              };
              try {
                if (entry == null) {
                  await _addDialect(newEntry);
                } else {
                  await _updateDialect(index!, newEntry);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving dialect: $e')));
              }
            },
            color: primary,
            textColor: white,
            width: 100,
            height: 40,
            fontSize: 14,
            radius: 8,
          ),
        ],
      ),
    );
  }

  void _deleteDialect(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
            text: 'Delete Entry?',
            fontSize: 18,
            color: Colors.red,
            fontFamily: 'Bold'),
        content:
            const Text('Are you sure you want to delete this dialect entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextWidget(
                text: 'Cancel',
                fontSize: 14,
                color: grey,
                fontFamily: 'Regular'),
          ),
          ButtonWidget(
            label: 'Delete',
            onPressed: () async {
              try {
                await _deleteDialectAt(index);
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting dialect: $e')));
              }
            },
            color: Colors.red,
            textColor: white,
            width: 100,
            height: 40,
            fontSize: 14,
            radius: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDialectCard(Map<String, dynamic> entry, int index, bool isWide) {
    return SizedBox(
      width: isWide ? 350 : double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: entry['phrase'],
                      fontSize: 16,
                      color: black,
                      fontFamily: 'Bold',
                    ),
                  ),
                  if (entry['verified'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextWidget(
                        text: 'Verified',
                        fontSize: 10,
                        color: Colors.green,
                        fontFamily: 'Medium',
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () =>
                        _showDialectDialog(entry: entry, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteDialect(index),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextWidget(
                text: 'Meaning: ${entry['meaning']}',
                fontSize: 13,
                color: grey,
                fontFamily: 'Regular',
              ),
              TextWidget(
                text: 'Pronunciation: ${entry['pronunciation']}',
                fontSize: 13,
                color: grey,
                fontFamily: 'Regular',
              ),
              TextWidget(
                text: 'Town: ${entry['town']}',
                fontSize: 13,
                color: grey,
                fontFamily: 'Regular',
              ),
              TextWidget(
                text: 'Language: ${entry['language']}',
                fontSize: 13,
                color: grey,
                fontFamily: 'Regular',
              ),
              TextWidget(
                text: 'Usage: ${entry['usage']}',
                fontSize: 13,
                color: grey,
                fontFamily: 'Regular',
              ),
              TextWidget(
                text: 'Example: ${entry['example']}',
                fontSize: 13,
                color: grey,
                fontFamily: 'Regular',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: TextWidget(
        text: title,
        fontSize: 20,
        color: primary,
        fontFamily: 'Bold',
        align: TextAlign.left,
      ),
    );
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
          text: 'Common Dialects Admin',
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
                    text: 'Crowdsourced Dialect Database',
                    fontSize: 28,
                    color: primary,
                    fontFamily: 'Bold',
                    align: TextAlign.left,
                  ),
                  const SizedBox(height: 10),
                  TextWidget(
                    text:
                        'Manage, verify, and explore common dialects and phrases across Aurora Province. Entries can be added, edited, verified, and deleted. Map integration and usage examples included.',
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
                      text: 'Dialect Entries',
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
                          hintText: 'Search by phrase, meaning, or usage',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ButtonWidget(
                      label: 'Add Entry',
                      onPressed: () => _showDialectDialog(),
                      color: primary,
                      textColor: white,
                      width: 120,
                      height: 40,
                      fontSize: 14,
                      radius: 8,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: towns.length,
                    itemBuilder: (context, index) {
                      final town = towns[index];
                      final isSelected = selectedTown == town;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedTown = town;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? primary : grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected ? primary : grey),
                            ),
                            child: TextWidget(
                              text: town,
                              fontSize: 14,
                              color: isSelected ? white : black,
                              fontFamily: isSelected ? 'Bold' : 'Regular',
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: filteredDialects
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildDialectCard(entry.value, entry.key, isWide))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: 'Sample Conversations',
                  fontSize: 22,
                  color: black,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 18),
                TextWidget(
                  text: 'Example 1: Greeting in Baler',
                  fontSize: 14,
                  color: black,
                  fontFamily: 'Medium',
                ),
                TextWidget(
                  text:
                      'You: Kumusta! (Hello!)\nLocal: Kumusta rin! Anong plano mo sa Baler? (Hello! What’s your plan in Baler?)',
                  fontSize: 12,
                  color: grey,
                  fontFamily: 'Regular',
                  maxLines: 4,
                ),
                const SizedBox(height: 8),
                TextWidget(
                  text: 'Example 2: Thanking in Maria Aurora',
                  fontSize: 14,
                  color: black,
                  fontFamily: 'Medium',
                ),
                TextWidget(
                  text:
                      'You: Agyamanak! (Thank you!)\nLocal: Awanan, nalaka! (You’re welcome, it’s easy!)',
                  fontSize: 12,
                  color: grey,
                  fontFamily: 'Regular',
                  maxLines: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
