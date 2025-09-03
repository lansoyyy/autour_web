import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'dart:core';
import 'package:universal_html/html.dart' as html;
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';

class CommunityEngagementAdminScreen extends StatefulWidget {
  const CommunityEngagementAdminScreen({super.key});

  @override
  State<CommunityEngagementAdminScreen> createState() =>
      _CommunityEngagementAdminScreenState();
}

class _CommunityEngagementAdminScreenState
    extends State<CommunityEngagementAdminScreen> {
  // Firestore
  // Initialize Firestore instance
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference storiesRef =
      firestore.collection('community_stories');
  late final CollectionReference heritageRef =
      firestore.collection('community_heritage');
  late final CollectionReference rulesRef =
      firestore.collection('community_rules');
  late final CollectionReference sustainabilityRef =
      firestore.collection('community_sustainability');
  late final CollectionReference preservationRef =
      firestore.collection('community_preservation');
  late final CollectionReference safetyStoriesRef =
      firestore.collection('safety_stories');
  late final CollectionReference dialectAlertsRef =
      firestore.collection('dialect_alerts');
  // New collections for additional sections
  late final CollectionReference culturalRespectRef =
      firestore.collection('community_cultural_respect');
  late final CollectionReference safetyGuidelinesRef =
      firestore.collection('community_safety_guidelines');
  late final CollectionReference communityGuidelinesRef =
      firestore.collection('community_community_guidelines');
  late final CollectionReference conservationEffortsRef =
      firestore.collection('community_conservation_efforts');
  late final CollectionReference culturalPreservationRef =
      firestore.collection('community_cultural_preservation');
  late final CollectionReference culturalSensitivityRef =
      firestore.collection('community_cultural_sensitivity');
  late final CollectionReference environmentalStewardshipRef =
      firestore.collection('community_environmental_stewardship');

  List<Map<String, String>> stories = [
    {
      'title': 'The Legend of Maria Aurora',
      'author': 'Lola Nena • Baler',
      'content':
          'A tale passed down for generations about a young maiden who protected the forest. Her bravery symbolizes Aurora\'s cultural strength.',
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Preserving the Bayanihan Spirit',
      'author': 'Barangay San Luis Youth',
      'content':
          'During community festivals, we practice bayanihan by helping each family prepare. This tradition reminds us to uplift one another.',
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Eco-Guiding by the Elders',
      'author': 'Manong Rudy • Casiguran',
      'content':
          'We guide visitors to our eco-sites, ensuring they understand the sacredness of nature and the importance of protecting it.',
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  // Document ID trackers for updates/deletes
  List<String> _storyIds = [];
  List<String> _heritageIds = [];
  List<String> _ruleIds = [];
  List<String> _sustainabilityIds = [];
  List<String> _preservationIds = [];
  List<String> _safetyStoryIds = [];
  List<String> _dialectAlertIds = [];
  // New ID trackers
  List<String> _culturalRespectIds = [];
  List<String> _safetyGuidelineIds = [];
  List<String> _communityGuidelineIds = [];
  List<String> _conservationEffortIds = [];
  List<String> _culturalPreservationIds = [];
  List<String> _culturalSensitivityIds = [];
  List<String> _environmentalStewardshipIds = [];

  @override
  void initState() {
    super.initState();
    _setupFirestoreListeners();
  }

  void _setupFirestoreListeners() {
    // Stories
    storiesRef.orderBy('createdAt', descending: true).snapshots().listen((s) {
      setState(() {
        stories = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'author': (data['author'] ?? '').toString(),
            'content': (data['content'] ?? '').toString(),
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _storyIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Heritage
    heritageRef.orderBy('createdAt', descending: true).snapshots().listen((s) {
      setState(() {
        heritageItems = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _heritageIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Rules
    rulesRef.orderBy('createdAt', descending: true).snapshots().listen((s) {
      setState(() {
        rulesAndRegulations = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'items': (data['items'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _ruleIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Sustainability
    sustainabilityRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        sustainabilityInfo = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'initiatives':
                (data['initiatives'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _sustainabilityIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Preservation
    preservationRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        touristPreservation = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'practices':
                (data['practices'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _preservationIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Safety Stories
    safetyStoriesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        safetyStories = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'author': (data['author'] ?? '').toString(),
            'content': (data['content'] ?? '').toString(),
            'category': (data['category'] ?? '').toString(),
            'location': (data['location'] ?? '').toString(),
            'verified': (data['verified'] ?? false) == true,
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _safetyStoryIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Dialect Alerts
    dialectAlertsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        dialectAlerts = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'dialect': (data['dialect'] ?? '').toString(),
            'alert': (data['alert'] ?? '').toString(),
            'translation': (data['translation'] ?? '').toString(),
            'location': (data['location'] ?? '').toString(),
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _dialectAlertIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Cultural Respect
    culturalRespectRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        culturalRespectItems = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _culturalRespectIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Safety Guidelines
    safetyGuidelinesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        safetyGuidelines = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'guidelines':
                (data['guidelines'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _safetyGuidelineIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Community Guidelines
    communityGuidelinesRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        communityGuidelines = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'points': (data['points'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _communityGuidelineIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Conservation Efforts
    conservationEffortsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        conservationEfforts = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'efforts': (data['efforts'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _conservationEffortIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Cultural Preservation
    culturalPreservationRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        culturalPreservation = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'methods': (data['methods'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _culturalPreservationIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Cultural Sensitivity
    culturalSensitivityRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        culturalSensitivity = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'practices':
                (data['practices'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _culturalSensitivityIds = s.docs.map((d) => d.id).toList();
      });
    });

    // Environmental Stewardship
    environmentalStewardshipRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((s) {
      setState(() {
        environmentalStewardship = s.docs.map((d) {
          final data = d.data() as Map<String, dynamic>;
          return {
            'title': (data['title'] ?? '').toString(),
            'description': (data['description'] ?? '').toString(),
            'actions': (data['actions'] as List?)?.cast<String>() ?? <String>[],
            'image': (data['image'] ?? '').toString(),
          };
        }).toList();
        _environmentalStewardshipIds = s.docs.map((d) => d.id).toList();
      });
    });
  }

  // CRUD Helpers
  Future<void> _addStory(Map<String, String> data) async {
    await storiesRef.add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> _updateStory(int index, Map<String, String> data) async {
    if (index < 0 || index >= _storyIds.length) return;
    await storiesRef.doc(_storyIds[index]).update(data);
  }

  Future<void> _deleteStoryAt(int index) async {
    if (index < 0 || index >= _storyIds.length) return;
    await storiesRef.doc(_storyIds[index]).delete();
  }

  Future<void> _addHeritage(Map<String, String> data) async {
    await heritageRef.add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> _updateHeritage(int index, Map<String, String> data) async {
    if (index < 0 || index >= _heritageIds.length) return;
    await heritageRef.doc(_heritageIds[index]).update(data);
  }

  Future<void> _deleteHeritageAt(int index) async {
    if (index < 0 || index >= _heritageIds.length) return;
    await heritageRef.doc(_heritageIds[index]).delete();
  }

  Future<void> _addRule(Map<String, dynamic> data) async {
    await rulesRef.add({
      ...data,
      'items': (data['items'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateRule(int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _ruleIds.length) return;
    await rulesRef.doc(_ruleIds[index]).update({
      ...data,
      'items': (data['items'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deleteRuleAt(int index) async {
    if (index < 0 || index >= _ruleIds.length) return;
    await rulesRef.doc(_ruleIds[index]).delete();
  }

  Future<void> _addSustainability(Map<String, dynamic> data) async {
    await sustainabilityRef.add({
      ...data,
      'initiatives':
          (data['initiatives'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateSustainability(
      int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _sustainabilityIds.length) return;
    await sustainabilityRef.doc(_sustainabilityIds[index]).update({
      ...data,
      'initiatives':
          (data['initiatives'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deleteSustainabilityAt(int index) async {
    if (index < 0 || index >= _sustainabilityIds.length) return;
    await sustainabilityRef.doc(_sustainabilityIds[index]).delete();
  }

  Future<void> _addPreservation(Map<String, dynamic> data) async {
    await preservationRef.add({
      ...data,
      'practices':
          (data['practices'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updatePreservation(int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _preservationIds.length) return;
    await preservationRef.doc(_preservationIds[index]).update({
      ...data,
      'practices':
          (data['practices'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deletePreservationAt(int index) async {
    if (index < 0 || index >= _preservationIds.length) return;
    await preservationRef.doc(_preservationIds[index]).delete();
  }

  Future<void> _addSafetyStory(Map<String, dynamic> data) async {
    await safetyStoriesRef.add({
      ...data,
      'verified': data['verified'] == true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateSafetyStory(int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _safetyStoryIds.length) return;
    await safetyStoriesRef.doc(_safetyStoryIds[index]).update({
      ...data,
      'verified': data['verified'] == true,
    });
  }

  Future<void> _deleteSafetyStoryAt(int index) async {
    if (index < 0 || index >= _safetyStoryIds.length) return;
    await safetyStoriesRef.doc(_safetyStoryIds[index]).delete();
  }

  Future<void> _addDialectAlert(Map<String, dynamic> data) async {
    await dialectAlertsRef.add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateDialectAlert(int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _dialectAlertIds.length) return;
    await dialectAlertsRef.doc(_dialectAlertIds[index]).update(data);
  }

  Future<void> _deleteDialectAlertAt(int index) async {
    if (index < 0 || index >= _dialectAlertIds.length) return;
    await dialectAlertsRef.doc(_dialectAlertIds[index]).delete();
  }

  // New CRUD helpers for additional sections
  Future<void> _addCulturalRespect(Map<String, String> data) async {
    await culturalRespectRef
        .add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> _updateCulturalRespect(
      int index, Map<String, String> data) async {
    if (index < 0 || index >= _culturalRespectIds.length) return;
    await culturalRespectRef.doc(_culturalRespectIds[index]).update(data);
  }

  Future<void> _deleteCulturalRespectAt(int index) async {
    if (index < 0 || index >= _culturalRespectIds.length) return;
    await culturalRespectRef.doc(_culturalRespectIds[index]).delete();
  }

  Future<void> _addSafetyGuideline(Map<String, dynamic> data) async {
    await safetyGuidelinesRef.add({
      ...data,
      'guidelines':
          (data['guidelines'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateSafetyGuideline(
      int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _safetyGuidelineIds.length) return;
    await safetyGuidelinesRef.doc(_safetyGuidelineIds[index]).update({
      ...data,
      'guidelines':
          (data['guidelines'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deleteSafetyGuidelineAt(int index) async {
    if (index < 0 || index >= _safetyGuidelineIds.length) return;
    await safetyGuidelinesRef.doc(_safetyGuidelineIds[index]).delete();
  }

  Future<void> _addCommunityGuideline(Map<String, dynamic> data) async {
    await communityGuidelinesRef.add({
      ...data,
      'points': (data['points'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateCommunityGuideline(
      int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _communityGuidelineIds.length) return;
    await communityGuidelinesRef.doc(_communityGuidelineIds[index]).update({
      ...data,
      'points': (data['points'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deleteCommunityGuidelineAt(int index) async {
    if (index < 0 || index >= _communityGuidelineIds.length) return;
    await communityGuidelinesRef.doc(_communityGuidelineIds[index]).delete();
  }

  Future<void> _addConservationEffort(Map<String, dynamic> data) async {
    await conservationEffortsRef.add({
      ...data,
      'efforts': (data['efforts'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateConservationEffort(
      int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _conservationEffortIds.length) return;
    await conservationEffortsRef.doc(_conservationEffortIds[index]).update({
      ...data,
      'efforts': (data['efforts'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deleteConservationEffortAt(int index) async {
    if (index < 0 || index >= _conservationEffortIds.length) return;
    await conservationEffortsRef.doc(_conservationEffortIds[index]).delete();
  }

  Future<void> _addCulturalPreservation(Map<String, dynamic> data) async {
    await culturalPreservationRef.add({
      ...data,
      'methods': (data['methods'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateCulturalPreservation(
      int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _culturalPreservationIds.length) return;
    await culturalPreservationRef.doc(_culturalPreservationIds[index]).update({
      ...data,
      'methods': (data['methods'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deleteCulturalPreservationAt(int index) async {
    if (index < 0 || index >= _culturalPreservationIds.length) return;
    await culturalPreservationRef.doc(_culturalPreservationIds[index]).delete();
  }

  Future<void> _addCulturalSensitivity(Map<String, dynamic> data) async {
    await culturalSensitivityRef.add({
      ...data,
      'practices':
          (data['practices'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateCulturalSensitivity(
      int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _culturalSensitivityIds.length) return;
    await culturalSensitivityRef.doc(_culturalSensitivityIds[index]).update({
      ...data,
      'practices':
          (data['practices'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deleteCulturalSensitivityAt(int index) async {
    if (index < 0 || index >= _culturalSensitivityIds.length) return;
    await culturalSensitivityRef.doc(_culturalSensitivityIds[index]).delete();
  }

  Future<void> _addEnvironmentalStewardship(Map<String, dynamic> data) async {
    await environmentalStewardshipRef.add({
      ...data,
      'actions': (data['actions'] as List).map((e) => e.toString()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateEnvironmentalStewardship(
      int index, Map<String, dynamic> data) async {
    if (index < 0 || index >= _environmentalStewardshipIds.length) return;
    await environmentalStewardshipRef
        .doc(_environmentalStewardshipIds[index])
        .update({
      ...data,
      'actions': (data['actions'] as List).map((e) => e.toString()).toList(),
    });
  }

  Future<void> _deleteEnvironmentalStewardshipAt(int index) async {
    if (index < 0 || index >= _environmentalStewardshipIds.length) return;
    await environmentalStewardshipRef
        .doc(_environmentalStewardshipIds[index])
        .delete();
  }

  void _showCulturalRespectDialog({Map<String, String>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName =
              'community_cultural_respect/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null
                  ? 'Add Cultural Respect Item'
                  : 'Edit Cultural Respect Item',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Item Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addCulturalRespect(data);
                          } else if (index != null) {
                            await _updateCulturalRespect(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error saving cultural respect: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteCulturalRespect(int index) async {
    try {
      await _deleteCulturalRespectAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting cultural respect: $e')));
    }
  }

  void _showSafetyGuidelineDialog({Map<String, dynamic>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final guidelinesController = TextEditingController(
        text: item != null ? (item['guidelines'] as List).join('\n') : '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName =
              'community_safety_guidelines/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null
                  ? 'Add Safety Guideline'
                  : 'Edit Safety Guideline',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: guidelinesController,
                      decoration: const InputDecoration(
                          labelText: 'Guidelines (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Guideline Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final guidelines = guidelinesController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'guidelines': guidelines,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addSafetyGuideline(data);
                          } else if (index != null) {
                            await _updateSafetyGuideline(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error saving safety guideline: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteSafetyGuideline(int index) async {
    try {
      await _deleteSafetyGuidelineAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting safety guideline: $e')));
    }
  }

  void _showCommunityGuidelineDialog({Map<String, dynamic>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final pointsController = TextEditingController(
        text: item != null ? (item['points'] as List).join('\n') : '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName =
              'community_community_guidelines/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null
                  ? 'Add Community Guideline'
                  : 'Edit Community Guideline',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: pointsController,
                      decoration: const InputDecoration(
                          labelText: 'Points (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Guideline Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final points = pointsController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'points': points,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addCommunityGuideline(data);
                          } else if (index != null) {
                            await _updateCommunityGuideline(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error saving community guideline: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteCommunityGuideline(int index) async {
    try {
      await _deleteCommunityGuidelineAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting community guideline: $e')));
    }
  }

  void _showConservationEffortDialog({Map<String, dynamic>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final effortsController = TextEditingController(
        text: item != null ? (item['efforts'] as List).join('\n') : '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName =
              'community_conservation_efforts/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null
                  ? 'Add Conservation Effort'
                  : 'Edit Conservation Effort',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: effortsController,
                      decoration: const InputDecoration(
                          labelText: 'Efforts (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Effort Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final efforts = effortsController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'efforts': efforts,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addConservationEffort(data);
                          } else if (index != null) {
                            await _updateConservationEffort(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error saving conservation effort: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteConservationEffort(int index) async {
    try {
      await _deleteConservationEffortAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting conservation effort: $e')));
    }
  }

  void _showCulturalPreservationDialog(
      {Map<String, dynamic>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final methodsController = TextEditingController(
        text: item != null ? (item['methods'] as List).join('\n') : '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName =
              'community_cultural_preservation/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null
                  ? 'Add Cultural Preservation'
                  : 'Edit Cultural Preservation',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: methodsController,
                      decoration: const InputDecoration(
                          labelText: 'Methods (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Preservation Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final methods = methodsController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'methods': methods,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addCulturalPreservation(data);
                          } else if (index != null) {
                            await _updateCulturalPreservation(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error saving cultural preservation: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteCulturalPreservation(int index) async {
    try {
      await _deleteCulturalPreservationAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting cultural preservation: $e')));
    }
  }

  void _showCulturalSensitivityDialog(
      {Map<String, dynamic>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final practicesController = TextEditingController(
        text: item != null ? (item['practices'] as List).join('\n') : '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName =
              'community_cultural_sensitivity/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null
                  ? 'Add Cultural Sensitivity'
                  : 'Edit Cultural Sensitivity',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: practicesController,
                      decoration: const InputDecoration(
                          labelText: 'Practices (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Sensitivity Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final practices = practicesController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'practices': practices,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addCulturalSensitivity(data);
                          } else if (index != null) {
                            await _updateCulturalSensitivity(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error saving cultural sensitivity: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteCulturalSensitivity(int index) async {
    try {
      await _deleteCulturalSensitivityAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting cultural sensitivity: $e')));
    }
  }

  void _showEnvironmentalStewardshipDialog(
      {Map<String, dynamic>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final actionsController = TextEditingController(
        text: item != null ? (item['actions'] as List).join('\n') : '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName =
              'community_environmental_stewardship/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null
                  ? 'Add Environmental Stewardship'
                  : 'Edit Environmental Stewardship',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: actionsController,
                      decoration: const InputDecoration(
                          labelText: 'Actions (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Stewardship Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final actions = actionsController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'actions': actions,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addEnvironmentalStewardship(data);
                          } else if (index != null) {
                            await _updateEnvironmentalStewardship(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Error saving environmental stewardship: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteEnvironmentalStewardship(int index) async {
    try {
      await _deleteEnvironmentalStewardshipAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting environmental stewardship: $e')));
    }
  }

  List<Map<String, String>> heritageItems = [
    {
      'title': 'Aurora Ancestral Languages',
      'description':
          'Languages like Ilongot, Tagalog, and Kapampangan reflect Aurora\'s identity. These preserve chants, rituals, and oral storytelling.',
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Traditional Dances & Music',
      'description':
          'Enjoy performances of Pandanggo, Harana, and tribal drumming. These arts show the creativity and soul of the community.',
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Cultural Dos and Don\'ts',
      'description':
          'Respect rituals, remove shoes in sacred homes, greet elders with honor, and observe traditions with mindfulness.',
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  List<Map<String, dynamic>> rulesAndRegulations = [
    {
      'title': 'Environmental Protection',
      'items': [
        'No littering in beaches, mountains, and public areas',
        'Proper waste disposal in designated bins only',
        'No collection of corals, shells, or marine life',
        'Respect protected areas and wildlife sanctuaries',
        'Follow designated trails in forest areas',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Cultural Respect',
      'items': [
        'Ask permission before taking photos of locals',
        'Respect sacred sites and religious ceremonies',
        'Dress modestly when visiting cultural sites',
        'Learn basic greetings in local languages',
        'Support local artisans and craftsmen',
      ]
    },
  ];

  List<Map<String, dynamic>> sustainabilityInfo = [
    {
      'title': 'Eco-Tourism Initiatives',
      'description':
          'Aurora promotes sustainable tourism practices that protect natural resources while supporting local communities.',
      'initiatives': [
        'Community-based tourism programs',
        'Eco-friendly accommodation options',
        'Local guide training and certification',
        'Waste management and recycling programs',
        'Renewable energy projects in remote areas',
      ]
    },
    {
      'title': 'Conservation Efforts',
      'description':
          'Active protection of Aurora\'s unique biodiversity and natural habitats.',
      'initiatives': [
        'Marine protected areas and sanctuaries',
        'Forest conservation and reforestation',
        'Wildlife protection and monitoring',
        'Water resource management',
        'Sustainable fishing practices',
      ]
    },
  ];

  List<Map<String, dynamic>> touristPreservation = [
    {
      'title': 'Responsible Tourism Practices',
      'description':
          'Guidelines for visitors to minimize environmental impact and support local communities.',
      'practices': [
        'Use eco-friendly transportation options',
        'Choose locally-owned accommodations',
        'Purchase souvenirs from local artisans',
        'Respect wildlife and natural habitats',
        'Participate in community-led tours',
      ]
    },
    {
      'title': 'Cultural Sensitivity',
      'description':
          'Understanding and respecting local customs, traditions, and social norms.',
      'practices': [
        'Learn about local customs before visiting',
        'Dress appropriately for cultural sites',
        'Ask permission before taking photos',
        'Respect religious and spiritual practices',
        'Support cultural preservation efforts',
      ]
    },
  ];

  List<Map<String, dynamic>> safetyStories = [
    {
      'title': 'Flash Flood Warning Signs',
      'author': 'Lolo Pedro • Baler',
      'content':
          'When the river water turns brown and you hear distant thunder, it means heavy rain upstream. The water will reach us in 30 minutes. Always move to higher ground immediately.',
      'category': 'Weather Safety',
      'location': 'Baler River Area',
      'verified': true,
    },
    {
      'title': 'Mountain Trail Safety',
      'author': 'Manang Maria • San Luis',
      'content':
          'Before climbing, check if the birds are flying low. If they are, strong winds are coming. Also, if the leaves are turning upside down, rain is approaching.',
      'category': 'Trail Safety',
      'location': 'San Luis Mountains',
      'verified': true,
    },
  ];

  List<Map<String, dynamic>> dialectAlerts = [
    {
      'dialect': 'Tagalog',
      'alert': 'Babala: Malakas na ulan sa bundok. Huwag mag-swimming sa ilog.',
      'translation':
          'Warning: Heavy rain in the mountains. Do not swim in the river.',
      'location': 'Baler Area',
    },
    {
      'dialect': 'Kapampangan',
      'alert':
          'Pamagbalu: Masakit a banua king bunduk. E kayu magpaligud king ilug.',
      'translation':
          'Warning: Bad weather in the mountains. Do not swim in the river.',
      'location': 'San Luis Area',
    },
  ];

  // New data structures for additional sections
  List<Map<String, String>> culturalRespectItems = [
    {
      'title': 'Respecting Local Customs',
      'description':
          'Understanding and honoring the traditions of Aurora\'s communities is essential for meaningful cultural exchange.',
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Sacred Sites Protocol',
      'description':
          'Many locations in Aurora hold spiritual significance. Always seek guidance from local elders before visiting these places.',
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  List<Map<String, dynamic>> safetyGuidelines = [
    {
      'title': 'Beach Safety',
      'description':
          'Important guidelines to ensure your safety while enjoying Aurora\'s beautiful coastlines.',
      'guidelines': [
        'Check weather conditions before swimming',
        'Swim only in designated areas with lifeguards',
        'Be aware of rip currents and how to escape them',
        'Apply reef-safe sunscreen to protect marine life',
        'Stay hydrated and take sun breaks',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Mountain Trekking Safety',
      'description':
          'Essential safety measures for exploring Aurora\'s mountain trails.',
      'guidelines': [
        'Hire local guides familiar with the terrain',
        'Inform someone of your hiking plans and expected return',
        'Carry sufficient water and emergency supplies',
        'Wear appropriate footwear and clothing',
        'Respect trail closures and weather warnings',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  List<Map<String, dynamic>> communityGuidelines = [
    {
      'title': 'Community Participation',
      'description':
          'Ways to engage respectfully with local Aurora communities.',
      'points': [
        'Participate in community events with genuine interest',
        'Purchase goods directly from local artisans',
        'Learn basic phrases in local dialects',
        'Respect community schedules and rest periods',
        'Contribute positively to community spaces',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Volunteer Guidelines',
      'description':
          'Best practices for volunteering in Aurora community projects.',
      'points': [
        'Commit to programs for meaningful duration',
        'Listen and learn from community leaders',
        'Respect local decision-making processes',
        'Bring skills that match community needs',
        'Leave personal agendas at home',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  List<Map<String, dynamic>> conservationEfforts = [
    {
      'title': 'Marine Conservation',
      'description':
          'Protecting Aurora\'s rich marine ecosystems for future generations.',
      'efforts': [
        'Establishing no-take zones in critical reef areas',
        'Training local fisherfolk in sustainable fishing techniques',
        'Monitoring coral health and restoration projects',
        'Reducing plastic waste through community programs',
        'Educating visitors about marine protection',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Forest Protection',
      'description': 'Preserving Aurora\'s lush forests and biodiversity.',
      'efforts': [
        'Reforestation with native tree species',
        'Preventing illegal logging through community patrols',
        'Protecting wildlife habitats and migration corridors',
        'Promoting agroforestry among local farmers',
        'Monitoring endangered species populations',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  List<Map<String, dynamic>> culturalPreservation = [
    {
      'title': 'Language Documentation',
      'description':
          'Preserving Aurora\'s rich linguistic heritage for future generations.',
      'methods': [
        'Recording elder storytellers and oral historians',
        'Creating digital dictionaries for local dialects',
        'Teaching traditional languages in community schools',
        'Documenting traditional songs and chants',
        'Training youth as language ambassadors',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Traditional Crafts',
      'description':
          'Keeping ancestral art forms alive through active preservation.',
      'methods': [
        'Establishing craft apprenticeship programs',
        'Creating market opportunities for artisans',
        'Documenting traditional techniques and patterns',
        'Integrating crafts into cultural education',
        'Supporting innovation within traditional forms',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  List<Map<String, dynamic>> culturalSensitivity = [
    {
      'title': 'Interpersonal Respect',
      'description':
          'Building meaningful relationships through cultural awareness.',
      'practices': [
        'Greet elders first in social settings',
        'Remove shoes when entering homes or sacred spaces',
        'Ask permission before photographing people',
        'Accept invitations with genuine gratitude',
        'Respect personal space and social norms',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Cultural Exchange Guidelines',
      'description': 'Approaching cultural learning with humility and respect.',
      'practices': [
        'Listen more than you speak',
        'Avoid comparing cultures as better or worse',
        'Participate authentically in cultural activities',
        'Respect when certain knowledge is not shared',
        'Share your own culture when invited',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  List<Map<String, dynamic>> environmentalStewardship = [
    {
      'title': 'Waste Management',
      'description':
          'Protecting Aurora\'s pristine environment through responsible waste practices.',
      'actions': [
        'Carry out all trash when visiting natural areas',
        'Use reusable water bottles and containers',
        'Participate in community clean-up events',
        'Properly dispose of biodegradable materials',
        'Support businesses with sustainable practices',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
    {
      'title': 'Energy Conservation',
      'description':
          'Reducing environmental impact through mindful energy use.',
      'actions': [
        'Use solar power when available in remote areas',
        'Turn off lights and electronics when not in use',
        'Choose accommodations with renewable energy sources',
        'Minimize the use of single-use plastics',
        'Support community renewable energy projects',
      ],
      'image':
          'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'
    },
  ];

  void _showStoryDialog({Map<String, String>? story, int? index}) {
    final titleController = TextEditingController(text: story?['title'] ?? '');
    final authorController =
        TextEditingController(text: story?['author'] ?? '');
    final contentController =
        TextEditingController(text: story?['content'] ?? '');
    final imageController = TextEditingController(text: story?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'community_stories/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: story == null ? 'Add Story' : 'Edit Story',
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
                      controller: authorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                    ),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Content'),
                      maxLines: 3,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Story Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (story == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final data = {
                          'title': titleController.text,
                          'author': authorController.text,
                          'content': contentController.text,
                          'image': imageUrl,
                        };

                        try {
                          if (story == null) {
                            await _addStory(data);
                          } else if (index != null) {
                            await _updateStory(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error saving story: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteStory(int index) async {
    try {
      await _deleteStoryAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting story: $e')),
      );
    }
  }

  void _showHeritageDialog({Map<String, String>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'community_heritage/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null ? 'Add Heritage Item' : 'Edit Heritage Item',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Heritage Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addHeritage(data);
                          } else if (index != null) {
                            await _updateHeritage(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error saving heritage: $e')),
                            );
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteHeritageItem(int index) async {
    try {
      await _deleteHeritageAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting heritage: $e')));
    }
  }

  void _showRuleDialog({Map<String, dynamic>? rule, int? index}) {
    final titleController = TextEditingController(text: rule?['title'] ?? '');
    final itemsController = TextEditingController(
        text: rule != null ? (rule['items'] as List).join('\n') : '');
    final imageController = TextEditingController(text: rule?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'community_rules/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: rule == null ? 'Add Rule' : 'Edit Rule',
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
                      controller: itemsController,
                      decoration: const InputDecoration(
                          labelText: 'Items (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Rule Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (rule == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final items = itemsController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'items': items,
                          'image': imageUrl,
                        };

                        try {
                          if (rule == null) {
                            await _addRule(data);
                          } else if (index != null) {
                            await _updateRule(index, data);
                          }
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error saving rule: $e')));
                        } finally {
                          setState(() {
                            _isImageUploading = false;
                          });
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteRule(int index) async {
    try {
      await _deleteRuleAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting rule: $e')));
    }
  }

  void _showSustainabilityDialog({Map<String, dynamic>? info, int? index}) {
    final titleController = TextEditingController(text: info?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: info?['description'] ?? '');
    final initiativesController = TextEditingController(
        text: info != null ? (info['initiatives'] as List).join('\n') : '');
    final imageController = TextEditingController(text: info?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'community_sustainability/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: info == null
                  ? 'Add Sustainability Initiative'
                  : 'Edit Sustainability Initiative',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: initiativesController,
                      decoration: const InputDecoration(
                          labelText: 'Initiatives (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Initiative Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (info == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final initiatives = initiativesController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'initiatives': initiatives,
                          'image': imageUrl,
                        };

                        try {
                          if (info == null) {
                            await _addSustainability(data);
                          } else if (index != null) {
                            await _updateSustainability(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Error saving sustainability: $e')));
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _deleteSustainability(int index) async {
    try {
      await _deleteSustainabilityAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting sustainability: $e')));
    }
  }

  void _deletePreservation(int index) async {
    try {
      await _deletePreservationAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting preservation: $e')));
    }
  }

  void _deleteSafetyStory(int index) async {
    try {
      await _deleteSafetyStoryAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting safety story: $e')));
    }
  }

  void _deleteDialectAlert(int index) async {
    try {
      await _deleteDialectAlertAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting dialect alert: $e')));
    }
  }

  void _showPreservationDialog({Map<String, dynamic>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final practicesController = TextEditingController(
        text: item != null ? (item['practices'] as List).join('\n') : '');
    final imageController = TextEditingController(text: item?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'community_preservation/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: item == null
                  ? 'Add Preservation Guideline'
                  : 'Edit Preservation Guideline',
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
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: practicesController,
                      decoration: const InputDecoration(
                          labelText: 'Practices (one per line)'),
                      maxLines: 5,
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Guideline Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (item == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final practices = practicesController.text
                            .split('\n')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList();
                        final data = {
                          'title': titleController.text,
                          'description': descriptionController.text,
                          'practices': practices,
                          'image': imageUrl,
                        };

                        try {
                          if (item == null) {
                            await _addPreservation(data);
                          } else if (index != null) {
                            await _updatePreservation(index, data);
                          }
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error saving preservation: $e')));
                        } finally {
                          setState(() {
                            _isImageUploading = false;
                          });
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDialectAlertDialog({Map<String, dynamic>? alert, int? index}) {
    final dialectController =
        TextEditingController(text: alert?['dialect'] ?? '');
    final alertController = TextEditingController(text: alert?['alert'] ?? '');
    final translationController =
        TextEditingController(text: alert?['translation'] ?? '');
    final locationController =
        TextEditingController(text: alert?['location'] ?? '');
    final imageController = TextEditingController(text: alert?['image'] ?? '');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'dialect_alerts/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: alert == null ? 'Add Dialect Alert' : 'Edit Dialect Alert',
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
                      controller: dialectController,
                      decoration: const InputDecoration(labelText: 'Dialect'),
                    ),
                    TextField(
                      controller: alertController,
                      decoration: const InputDecoration(labelText: 'Alert'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: translationController,
                      decoration:
                          const InputDecoration(labelText: 'Translation'),
                      maxLines: 2,
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Alert Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (alert == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final data = {
                          'dialect': dialectController.text,
                          'alert': alertController.text,
                          'translation': translationController.text,
                          'location': locationController.text,
                          'image': imageUrl,
                        };

                        try {
                          if (alert == null) {
                            await _addDialectAlert(data);
                          } else if (index != null) {
                            await _updateDialectAlert(index, data);
                          }
                          Navigator.pop(context);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Error saving dialect alert: $e')));
                        } finally {
                          setState(() {
                            _isImageUploading = false;
                          });
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
      ),
    );
  }

  // Remove all the duplicate and corrupted code
  // The correct functions are already defined elsewhere in the file

  void _showSafetyStoryDialog({Map<String, dynamic>? story, int? index}) {
    final titleController = TextEditingController(text: story?['title'] ?? '');
    final authorController =
        TextEditingController(text: story?['author'] ?? '');
    final contentController =
        TextEditingController(text: story?['content'] ?? '');
    final categoryController =
        TextEditingController(text: story?['category'] ?? '');
    final locationController =
        TextEditingController(text: story?['location'] ?? '');
    final imageController = TextEditingController(text: story?['image'] ?? '');
    final verifiedController =
        TextEditingController(text: story?['verified'].toString() ?? 'false');
    final formKey = GlobalKey<FormState>();

    // Variables for image handling
    Uint8List? _webImageBytes;
    String? _imageName;
    bool _isImageUploading = false;

    // Function to pick image using web file input
    Future<void> _pickImage(StateSetter setState) async {
      // Create an input element for file selection
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'image/*'
            ..multiple = false;

      // Add a change listener to handle file selection
      uploadInput.onChange.listen((e) async {
        if (uploadInput.files!.isNotEmpty) {
          final file = uploadInput.files![0];

          // Read the file as bytes
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            if (reader.result != null) {
              final bytes = Uint8List.fromList(reader.result as List<int>);
              setState(() {
                _webImageBytes = bytes;
                _imageName = file.name;
              });
            }
          });
        }
      });

      // Trigger the file selection dialog
      uploadInput.click();
    }

    // Function to upload image to Firebase Storage
    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'safety_stories/${timestamp}_$_imageName';

          // Create a reference to the image file
          final imageRef = storageRef.child(imageName);

          // Upload the file
          final uploadTask = imageRef.putData(_webImageBytes!);

          // Wait for the upload to complete
          final snapshot = await uploadTask;

          // Get the download URL
          final downloadUrl = await snapshot.ref.getDownloadURL();

          return downloadUrl;
        } catch (e) {
          print('Error uploading image: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
          return null;
        }
      }

      // If we don't have image bytes but have a URL in the controller, use that
      if (imageController.text.isNotEmpty) {
        return imageController.text;
      }

      return null;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: TextWidget(
              text: story == null ? 'Add Safety Story' : 'Edit Safety Story',
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
                      controller: authorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                    ),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(labelText: 'Content'),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location'),
                    ),
                    TextField(
                      controller: verifiedController,
                      decoration: const InputDecoration(
                          labelText: 'Verified (true/false)'),
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Story Image',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: _isImageUploading
                                  ? null
                                  : () => _pickImage(setState),
                              child: Text(_webImageBytes != null
                                  ? 'Change Image'
                                  : 'Select Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_webImageBytes != null)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _webImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else if (imageController.text.isNotEmpty)
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: primary, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primary.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageController.text,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: Colors.red,
                                            size: 40),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: grey, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                  color: grey.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.image,
                                  color: grey,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                        if (_webImageBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  'Image selected: $_imageName',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'Existing image loaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'No image selected',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: imageController,
                          decoration: const InputDecoration(
                            labelText: 'Or enter Image URL',
                            hintText: 'https://example.com/image.jpg',
                          ),
                        ),
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
                  fontFamily: 'Regular',
                ),
              ),
              ButtonWidget(
                label: _isImageUploading
                    ? 'Uploading...'
                    : (story == null ? 'Add' : 'Update'),
                onPressed: _isImageUploading
                    ? () {}
                    : () async {
                        if (formKey.currentState == null ||
                            !formKey.currentState!.validate()) return;

                        setState(() {
                          _isImageUploading = true;
                        });

                        String? imageUrl = imageController.text;

                        // Upload image if selected
                        if (_webImageBytes != null) {
                          imageUrl = await _uploadImageToFirebase();
                          if (imageUrl == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Failed to upload image. Please try again.'),
                              ),
                            );
                            setState(() {
                              _isImageUploading = false;
                            });
                            return;
                          }
                        }

                        final data = {
                          'title': titleController.text,
                          'author': authorController.text,
                          'content': contentController.text,
                          'category': categoryController.text,
                          'location': locationController.text,
                          'verified':
                              verifiedController.text.toLowerCase() == 'true',
                          'image': imageUrl,
                        };

                        try {
                          if (story == null) {
                            await _addSafetyStory(data);
                          } else if (index != null) {
                            await _updateSafetyStory(index, data);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Error saving safety story: $e')));
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() {
                              _isImageUploading = false;
                            });
                          }
                        }
                      },
                color: primary,
                textColor: white,
                width: 100,
                height: 45,
                fontSize: 16,
                radius: 10,
              ),
            ],
          );
        },
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
        title: TextWidget(
          text: 'Community & Cultural Preservation',
          fontSize: 20,
          color: white,
          fontFamily: 'Bold',
        ),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(40),
        children: [
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
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
                  text: 'Welcome to Aurora Province',
                  fontSize: 28,
                  color: primary,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 12),
                TextWidget(
                  text:
                      'Located in the eastern part of Luzon, Aurora is a hidden gem filled with lush mountains, scenic coastlines, and a rich blend of indigenous and colonial culture. It is known for sustainable tourism, ancestral traditions, and a strong sense of community.',
                  fontSize: 16,
                  color: black,
                  fontFamily: 'Regular',
                  maxLines: 20,
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
                Row(
                  children: [
                    TextWidget(
                      text: 'Voices of Aurora',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Story'),
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
                      onPressed: () => _showStoryDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: stories
                      .asMap()
                      .entries
                      .map((entry) => _buildStoryCard(
                          context, entry.value, entry.key, isWide))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Heritage Education',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Heritage'),
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
                      onPressed: () => _showHeritageDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: heritageItems
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildHeritageCard(entry.value, entry.key, isWide))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Rules & Regulations',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Rule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showRuleDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: rulesAndRegulations
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildRulesCard(entry.value, entry.key, isWide))
                      .toList(),
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
                    TextWidget(
                      text: 'Sustainability Initiatives',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Initiative'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showSustainabilityDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: sustainabilityInfo
                      .asMap()
                      .entries
                      .map((entry) => _buildSustainabilityCard(
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
              color: Colors.green.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Tourist Preservation Guidelines',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Guideline'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showPreservationDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: touristPreservation
                      .asMap()
                      .entries
                      .map((entry) => _buildPreservationCard(
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
                Row(
                  children: [
                    TextWidget(
                      text: 'Safety Stories & Traditional Knowledge',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Story'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showSafetyStoryDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: safetyStories
                      .asMap()
                      .entries
                      .map((entry) =>
                          _buildSafetyStoryCard(entry.value, entry.key, isWide))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Local Dialect Alerts',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Alert'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showDialectAlertDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: dialectAlerts
                      .asMap()
                      .entries
                      .map((entry) => _buildDialectAlertCard(
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
              color: Colors.purple.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Cultural Respect',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showCulturalRespectDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: culturalRespectItems
                      .asMap()
                      .entries
                      .map((entry) => _buildCulturalRespectCard(
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
              color: Colors.indigo.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Safety Guidelines',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Guideline'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showSafetyGuidelineDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: safetyGuidelines
                      .asMap()
                      .entries
                      .map((entry) => _buildSafetyGuidelineCard(
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
              color: Colors.teal.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Community Guidelines',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Guideline'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showCommunityGuidelineDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: communityGuidelines
                      .asMap()
                      .entries
                      .map((entry) => _buildCommunityGuidelineCard(
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
              color: Colors.lightGreen.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Conservation Efforts',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Effort'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showConservationEffortDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: conservationEfforts
                      .asMap()
                      .entries
                      .map((entry) => _buildConservationEffortCard(
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
              color: Colors.deepOrange.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Cultural Preservation',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Method'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showCulturalPreservationDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: culturalPreservation
                      .asMap()
                      .entries
                      .map((entry) => _buildCulturalPreservationCard(
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
              color: Colors.pink.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Cultural Sensitivity',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Practice'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showCulturalSensitivityDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: culturalSensitivity
                      .asMap()
                      .entries
                      .map((entry) => _buildCulturalSensitivityCard(
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
              color: Colors.cyan.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TextWidget(
                      text: 'Environmental Stewardship',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Action'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showEnvironmentalStewardshipDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: environmentalStewardship
                      .asMap()
                      .entries
                      .map((entry) => _buildEnvironmentalStewardshipCard(
                          entry.value, entry.key, isWide))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStoryCard(
      BuildContext context, Map<String, String> story, int index, bool isWide) {
    return SizedBox(
      width: isWide ? 350 : double.infinity,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                story['image']!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: story['title']!,
                          fontSize: 16,
                          color: white,
                          fontFamily: 'Bold',
                        ),
                        TextWidget(
                          text: story['author']!,
                          fontSize: 12,
                          color: white.withOpacity(0.85),
                          fontFamily: 'Regular',
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () =>
                        _showStoryDialog(story: story, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteStory(index),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeritageCard(Map<String, String> item, int index, bool isWide) {
    return SizedBox(
      width: isWide ? 350 : double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item['image'] ??
                        'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: item['title']!,
                      fontSize: 16,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(height: 6),
                    TextWidget(
                      text: item['description']!,
                      fontSize: 13,
                      color: black,
                      fontFamily: 'Regular',
                      maxLines: 20,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () => _showHeritageDialog(item: item, index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteHeritageItem(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRulesCard(Map<String, dynamic> rule, int index, bool isWide) {
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
              // Image display for rules
              if (rule['image'] != null && rule['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(rule['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: rule['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () => _showRuleDialog(rule: rule, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteRuleAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...(rule['items'] as List).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: item,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSustainabilityCard(
      Map<String, dynamic> info, int index, bool isWide) {
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
              // Image display for sustainability
              if (info['image'] != null && info['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(info['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: info['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () =>
                        _showSustainabilityDialog(info: info, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteSustainabilityAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextWidget(
                text: info['description']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              ...(info['initiatives'] as List).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.trending_up, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: item,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreservationCard(
      Map<String, dynamic> item, int index, bool isWide) {
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
              // Image display for preservation
              if (item['image'] != null && item['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: item['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () =>
                        _showPreservationDialog(item: item, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deletePreservationAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextWidget(
                text: item['description']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              ...(item['practices'] as List).map((practice) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.handshake, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: practice,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyStoryCard(
      Map<String, dynamic> story, int index, bool isWide) {
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
              // Image display for safety story
              if (story['image'] != null &&
                  story['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(story['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: story['title']!,
                      fontSize: 16,
                      color: black,
                      fontFamily: 'Bold',
                    ),
                  ),
                  if (story['verified'] == true)
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
                        _showSafetyStoryDialog(story: story, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteSafetyStoryAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              TextWidget(
                text: story['author']!,
                fontSize: 12,
                color: grey,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: story['content']!,
                fontSize: 13,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextWidget(
                      text: story['category']!,
                      fontSize: 10,
                      color: primary,
                      fontFamily: 'Medium',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on, color: Colors.grey, size: 12),
                  const SizedBox(width: 2),
                  TextWidget(
                    text: story['location']!,
                    fontSize: 10,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialectAlertCard(
      Map<String, dynamic> alert, int index, bool isWide) {
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
              // Image display for dialect alert
              if (alert['image'] != null &&
                  alert['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(alert['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: TextWidget(
                      text: alert['dialect']!,
                      fontSize: 10,
                      color: Colors.orange,
                      fontFamily: 'Bold',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on, color: Colors.grey, size: 12),
                  const SizedBox(width: 2),
                  TextWidget(
                    text: alert['location']!,
                    fontSize: 10,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () =>
                        _showDialectAlertDialog(alert: alert, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteDialectAlertAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: alert['alert']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Medium',
              ),
              const SizedBox(height: 4),
              Text(
                alert['translation']!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Baloo2-Regular',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCulturalRespectCard(
      Map<String, String> item, int index, bool isWide) {
    return SizedBox(
      width: isWide ? 350 : double.infinity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item['image'] ??
                        'https://outoftownblog.com/wp-content/uploads/2014/03/Dona-Aurora-Aragon-Quezon-House-600x398.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: item['title']!,
                      fontSize: 16,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(height: 6),
                    TextWidget(
                      text: item['description']!,
                      fontSize: 13,
                      color: black,
                      fontFamily: 'Regular',
                      maxLines: 20,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black),
                onPressed: () =>
                    _showCulturalRespectDialog(item: item, index: index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteCulturalRespectAt(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyGuidelineCard(
      Map<String, dynamic> item, int index, bool isWide) {
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
              // Image display for safety guidelines
              if (item['image'] != null && item['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: item['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () =>
                        _showSafetyGuidelineDialog(item: item, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteSafetyGuidelineAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextWidget(
                text: item['description']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              ...(item['guidelines'] as List).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.security, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: item,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityGuidelineCard(
      Map<String, dynamic> item, int index, bool isWide) {
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
              // Image display for community guidelines
              if (item['image'] != null && item['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: item['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () =>
                        _showCommunityGuidelineDialog(item: item, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteCommunityGuidelineAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextWidget(
                text: item['description']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              ...(item['points'] as List).map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.people, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: point,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConservationEffortCard(
      Map<String, dynamic> item, int index, bool isWide) {
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
              // Image display for conservation efforts
              if (item['image'] != null && item['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: item['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () =>
                        _showConservationEffortDialog(item: item, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteConservationEffortAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextWidget(
                text: item['description']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              ...(item['efforts'] as List).map((effort) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.eco, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: effort,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCulturalPreservationCard(
      Map<String, dynamic> item, int index, bool isWide) {
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
              // Image display for cultural preservation
              if (item['image'] != null && item['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: item['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () => _showCulturalPreservationDialog(
                        item: item, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteCulturalPreservationAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextWidget(
                text: item['description']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              ...(item['methods'] as List).map((method) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_stories,
                            color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: method,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCulturalSensitivityCard(
      Map<String, dynamic> item, int index, bool isWide) {
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
              // Image display for cultural sensitivity
              if (item['image'] != null && item['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: item['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () => _showCulturalSensitivityDialog(
                        item: item, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteCulturalSensitivityAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextWidget(
                text: item['description']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              ...(item['practices'] as List).map((practice) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.handshake, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: practice,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentalStewardshipCard(
      Map<String, dynamic> item, int index, bool isWide) {
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
              // Image display for environmental stewardship
              if (item['image'] != null && item['image'].toString().isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(item['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: TextWidget(
                      text: item['title']!,
                      fontSize: 18,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () => _showEnvironmentalStewardshipDialog(
                        item: item, index: index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteEnvironmentalStewardshipAt(index),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextWidget(
                text: item['description']!,
                fontSize: 14,
                color: black,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 12),
              ...(item['actions'] as List).map((action) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.recycling, color: primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextWidget(
                            text: action,
                            fontSize: 14,
                            color: black,
                            fontFamily: 'Regular',
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
