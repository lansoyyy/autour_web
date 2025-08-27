import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
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
          };
        }).toList();
        _dialectAlertIds = s.docs.map((d) => d.id).toList();
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

  List<Map<String, String>> heritageItems = [
    {
      'title': 'Aurora Ancestral Languages',
      'description':
          'Languages like Ilongot, Tagalog, and Kapampangan reflect Aurora\'s identity. These preserve chants, rituals, and oral storytelling.',
    },
    {
      'title': 'Traditional Dances & Music',
      'description':
          'Enjoy performances of Pandanggo, Harana, and tribal drumming. These arts show the creativity and soul of the community.',
    },
    {
      'title': 'Cultural Dos and Don\'ts',
      'description':
          'Respect rituals, remove shoes in sacred homes, greet elders with honor, and observe traditions with mindfulness.',
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
      ]
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
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
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
            label: item == null ? 'Add' : 'Update',
            onPressed: () async {
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              final data = {
                'title': titleController.text,
                'description': descriptionController.text,
              };
              try {
                if (item == null) {
                  await _addHeritage(data);
                } else if (index != null) {
                  await _updateHeritage(index, data);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving heritage: $e')));
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
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  decoration:
                      const InputDecoration(labelText: 'Items (one per line)'),
                  maxLines: 5,
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
            label: rule == null ? 'Add' : 'Update',
            onPressed: () async {
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              final items = itemsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              final data = {
                'title': titleController.text,
                'items': items,
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
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                TextField(
                  controller: initiativesController,
                  decoration: const InputDecoration(
                      labelText: 'Initiatives (one per line)'),
                  maxLines: 5,
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
            label: info == null ? 'Add' : 'Update',
            onPressed: () async {
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              final initiatives = initiativesController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              final data = {
                'title': titleController.text,
                'description': descriptionController.text,
                'initiatives': initiatives,
              };
              try {
                if (info == null) {
                  await _addSustainability(data);
                } else if (index != null) {
                  await _updateSustainability(index, data);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving sustainability: $e')));
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

  void _showPreservationDialog({Map<String, dynamic>? item, int? index}) {
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descriptionController =
        TextEditingController(text: item?['description'] ?? '');
    final practicesController = TextEditingController(
        text: item != null ? (item['practices'] as List).join('\n') : '');
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
                TextField(
                  controller: practicesController,
                  decoration: const InputDecoration(
                      labelText: 'Practices (one per line)'),
                  maxLines: 5,
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
            label: item == null ? 'Add' : 'Update',
            onPressed: () async {
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              final practices = practicesController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              final data = {
                'title': titleController.text,
                'description': descriptionController.text,
                'practices': practices,
              };
              try {
                if (item == null) {
                  await _addPreservation(data);
                } else if (index != null) {
                  await _updatePreservation(index, data);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving preservation: $e')));
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
      ),
    );
  }

  void _deletePreservation(int index) async {
    try {
      await _deletePreservationAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting preservation: $e')));
    }
  }

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
    bool verified = story?['verified'] ?? false;
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                Row(
                  children: [
                    Checkbox(
                      value: verified,
                      onChanged: (val) {
                        setState(() {
                          verified = val ?? false;
                        });
                      },
                    ),
                    const Text('Verified'),
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
            label: story == null ? 'Add' : 'Update',
            onPressed: () async {
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              final data = {
                'title': titleController.text,
                'author': authorController.text,
                'content': contentController.text,
                'category': categoryController.text,
                'location': locationController.text,
                'verified': verified,
              };
              try {
                if (story == null) {
                  await _addSafetyStory(data);
                } else if (index != null) {
                  await _updateSafetyStory(index, data);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving safety story: $e')));
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
      ),
    );
  }

  void _deleteSafetyStory(int index) async {
    try {
      await _deleteSafetyStoryAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting safety story: $e')));
    }
  }

  void _showDialectAlertDialog({Map<String, dynamic>? alert, int? index}) {
    final dialectController =
        TextEditingController(text: alert?['dialect'] ?? '');
    final alertController = TextEditingController(text: alert?['alert'] ?? '');
    final translationController =
        TextEditingController(text: alert?['translation'] ?? '');
    final locationController =
        TextEditingController(text: alert?['location'] ?? '');
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  decoration: const InputDecoration(labelText: 'Translation'),
                  maxLines: 2,
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
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
            label: alert == null ? 'Add' : 'Update',
            onPressed: () async {
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              final data = {
                'dialect': dialectController.text,
                'alert': alertController.text,
                'translation': translationController.text,
                'location': locationController.text,
              };
              try {
                if (alert == null) {
                  await _addDialectAlert(data);
                } else if (index != null) {
                  await _updateDialectAlert(index, data);
                }
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving dialect alert: $e')));
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
      ),
    );
  }

  void _deleteDialectAlert(int index) async {
    try {
      await _deleteDialectAlertAt(index);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting dialect alert: $e')));
    }
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
                    image: NetworkImage(
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
                    onPressed: () => _deleteRule(index),
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
                    onPressed: () => _deleteSustainability(index),
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
                    onPressed: () => _deletePreservation(index),
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
                    onPressed: () => _deleteSafetyStory(index),
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
                    onPressed: () => _deleteDialectAlert(index),
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
}
