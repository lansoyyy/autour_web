import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'package:autour_web/widgets/textfield_widget.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart'; // Added for launching URLs
import 'package:url_launcher/url_launcher.dart'; // Added for launching URLs

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class Business {
  String name;
  String category;
  String location;
  String description;
  String? registrationNumber; // New field for registration number
  String? phone;
  String? email;
  String? hours;
  int? roomsAvailable;
  int? totalRooms;
  List<String>? roomTypes;
  String? priceRange;
  Map<String, dynamic>? prices;
  Map<String, dynamic>? fares;
  String? image;
  // Social media fields
  String? tiktok;
  String? facebook;
  String? instagram;
  String? telegram;
  // Geolocation fields
  double? latitude;
  double? longitude;
  // Municipality field
  String? municipality;
  // Timestamp fields for room availability and pricing
  DateTime? roomAvailabilityLastUpdated;
  DateTime? priceLastUpdated;

  Business({
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    this.registrationNumber,
    this.phone,
    this.email,
    this.hours,
    this.roomsAvailable,
    this.totalRooms,
    this.roomTypes,
    this.priceRange,
    this.prices,
    this.fares,
    this.image,
    this.tiktok,
    this.facebook,
    this.instagram,
    this.telegram,
    this.latitude,
    this.longitude,
    this.municipality,
    this.roomAvailabilityLastUpdated,
    this.priceLastUpdated,
  });

  // Convert Business object to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'location': location,
      'description': description,
      'registrationNumber': registrationNumber,
      'phone': phone,
      'email': email,
      'hours': hours,
      'roomsAvailable': roomsAvailable,
      'totalRooms': totalRooms,
      'roomTypes': roomTypes,
      'priceRange': priceRange,
      'prices': prices,
      'fares': fares,
      'image': image,
      'tiktok': tiktok,
      'facebook': facebook,
      'instagram': instagram,
      'telegram': telegram,
      'latitude': latitude,
      'longitude': longitude,
      'municipality': municipality,
      'roomAvailabilityLastUpdated':
          roomAvailabilityLastUpdated?.toIso8601String(),
      'priceLastUpdated': priceLastUpdated?.toIso8601String(),
    };
  }

  // Create Business object from Firestore map
  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      name: map['name'],
      category: map['category'],
      location: map['location'],
      description: map['description'],
      registrationNumber: map['registrationNumber'],
      phone: map['phone'],
      email: map['email'],
      hours: map['hours'],
      roomsAvailable: map['roomsAvailable'],
      totalRooms: map['totalRooms'],
      roomTypes: List<String>.from(map['roomTypes'] ?? []),
      priceRange: map['priceRange'],
      prices: Map<String, dynamic>.from(map['prices'] ?? {}),
      fares: Map<String, dynamic>.from(map['fares'] ?? {}),
      image: map['image'],
      tiktok: map['tiktok'],
      facebook: map['facebook'],
      instagram: map['instagram'],
      telegram: map['telegram'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      municipality: map['municipality'],
      roomAvailabilityLastUpdated: map['roomAvailabilityLastUpdated'] != null
          ? DateTime.parse(map['roomAvailabilityLastUpdated'])
          : null,
      priceLastUpdated: map['priceLastUpdated'] != null
          ? DateTime.parse(map['priceLastUpdated'])
          : null,
    );
  }
}

class LocalBusinessesAdminScreen extends StatefulWidget {
  const LocalBusinessesAdminScreen({super.key});

  @override
  State<LocalBusinessesAdminScreen> createState() =>
      _LocalBusinessesAdminScreenState();
}

class _LocalBusinessesAdminScreenState
    extends State<LocalBusinessesAdminScreen> {
  final CollectionReference businessesRef = firestore.collection('businesses');

  final List<String> categories = [
    'All',
    'Accommodations',
    'Restaurants',
    'Markets',
    'Transportation',
    'Services',
    'Tours',
  ];

  // Municipalities in Aurora Province
  final List<String> municipalities = [
    'All',
    'Baler',
    'Casiguran',
    'Dilasag',
    'Dinalungan',
    'Dingalan',
    'Dipaculao',
    'Maria Aurora',
    'San Luis',
  ];

  // For adding new categories
  final Set<String> _customCategories = <String>{};

  String selectedCategory = 'All';
  String selectedMunicipality = 'All';
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<Business> businesses = [];
  List<String> businessIds = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isMapView = false;

  // Simulate user role (in a real app, this would come from authentication)
  final bool _isUserAdmin = true; // Set to false for business owner role

  void _setupFirestoreListener() {
    businessesRef.snapshots().listen((snapshot) {
      setState(() {
        businesses = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Business.fromMap(data);
        }).toList();
        businessIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    });
  }

  Future<void> addBusiness(Business business) async {
    await businessesRef.add(business.toMap());
  }

  Future<void> updateBusiness(String id, Business business) async {
    await businessesRef.doc(id).update(business.toMap());
  }

  Future<void> deleteBusiness(String id) async {
    try {
      await businessesRef.doc(id).delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting business: ${e.toString()}')),
      );
    }
  }

  // Method to add a new category
  void _addNewCategory(String category) {
    if (category.isNotEmpty && !categories.contains(category)) {
      setState(() {
        categories.add(category);
        _customCategories.add(category);
      });
    }
  }

  void _showBusinessDialog({Business? business, String? id}) {
    final nameController = TextEditingController(text: business?.name ?? '');
    String selectedCategory = business?.category ??
        categories[1]; // Default to first non-'All' category
    String selectedMunicipality = business?.municipality ??
        municipalities[1]; // Default to first non-'All' municipality
    final locationController =
        TextEditingController(text: business?.location ?? '');
    final descriptionController =
        TextEditingController(text: business?.description ?? '');
    final registrationNumberController = TextEditingController(
        text: business?.registrationNumber ?? ''); // New field
    final phoneController = TextEditingController(text: business?.phone ?? '');
    final emailController = TextEditingController(text: business?.email ?? '');
    final hoursController = TextEditingController(text: business?.hours ?? '');
    final roomsAvailableController =
        TextEditingController(text: business?.roomsAvailable?.toString() ?? '');
    final totalRoomsController =
        TextEditingController(text: business?.totalRooms?.toString() ?? '');
    final roomTypesController =
        TextEditingController(text: business?.roomTypes?.join(', ') ?? '');
    final priceRangeController =
        TextEditingController(text: business?.priceRange ?? '');
    final faresController =
        TextEditingController(text: business?.fares?.toString() ?? '');
    final pricesController = TextEditingController(
      text: business?.prices?.entries
              .map((e) =>
                  '${e.key}: ${e.value.entries.map((v) => '${v.key}=${v.value}').join(',')}|')
              .join('') ??
          '',
    );
    final imageController = TextEditingController(text: business?.image ?? '');
    // Social media controllers
    final tiktokController =
        TextEditingController(text: business?.tiktok ?? '');
    final facebookController =
        TextEditingController(text: business?.facebook ?? '');
    final instagramController =
        TextEditingController(text: business?.instagram ?? '');
    final telegramController =
        TextEditingController(text: business?.telegram ?? '');
    // Geolocation controllers
    final latitudeController =
        TextEditingController(text: business?.latitude?.toString() ?? '');
    final longitudeController =
        TextEditingController(text: business?.longitude?.toString() ?? '');
    // New category controller
    final newCategoryController = TextEditingController();

    final formKey = GlobalKey<FormState>();
    String? _uploadedImageUrl;
    Uint8List? _webImageBytes;
    String? _imageName;
    // Map variables
    LatLng? _selectedLocation =
        business?.latitude != null && business?.longitude != null
            ? LatLng(business!.latitude!, business.longitude!)
            : null;
    MapController mapController = MapController();

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

    Future<String?> _uploadImageToFirebase() async {
      // If we have web image bytes, we can upload those
      if (_webImageBytes != null && _imageName != null) {
        try {
          // Create a reference to the Firebase Storage bucket
          final storageRef = FirebaseStorage.instance.ref();

          // Generate a unique filename
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final imageName = 'business_images/${timestamp}_$_imageName';

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

    // Function to handle map tap for location selection
    void _handleMapTap(LatLng latLng, StateSetter setState) {
      setState(() {
        _selectedLocation = latLng;
        latitudeController.text = latLng.latitude.toString();
        longitudeController.text = latLng.longitude.toString();
      });
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: business == null ? 'Add New Business' : 'Edit Business',
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: StatefulBuilder(builder: (context, setState) {
          return SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Business Name field with role-based editing restriction
                    TextFieldWidget(
                      label: 'Business Name',
                      controller: nameController,
                      borderColor: primary,
                      hintColor: grey,
                      width: 350,
                      height: 60,
                      radius: 10,
                      hasValidator: true,
                      enabled:
                          _isUserAdmin, // Only admins can edit business name
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter business name'
                          : null,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Registration Number field
                    TextFieldWidget(
                      label: 'Registration Number',
                      controller: registrationNumberController,
                      borderColor: primary,
                      hintColor: grey,
                      width: 350,
                      height: 60,
                      radius: 10,
                      hasValidator: false,
                      enabled:
                          _isUserAdmin, // Only admins can edit registration number
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Municipality dropdown
                    SizedBox(
                      width: 350,
                      height: 60,
                      child: DropdownButtonFormField<String>(
                        value: selectedMunicipality,
                        items: municipalities
                            .where((m) => m != 'All')
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedMunicipality = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: 'Municipality',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Category dropdown with add new category option
                    SizedBox(
                      width: 350,
                      height: 60,
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: categories
                            .where((c) => c != 'All')
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white),
                      ),
                    ),
                    // Add new category section
                    if (_isUserAdmin) // Only admins can add new categories
                      Column(
                        children: [
                          SizedBox(height: 10),
                          TextFieldWidget(
                            label: 'Add New Category',
                            controller: newCategoryController,
                            borderColor: primary,
                            hintColor: grey,
                            width: 350,
                            height: 60,
                            radius: 10,
                            hasValidator: false,
                            hint: 'Enter new category name',
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            onPressed: () {
                              if (newCategoryController.text.isNotEmpty) {
                                _addNewCategory(newCategoryController.text);
                                newCategoryController.clear();
                                setState(() {}); // Refresh the dropdown
                              }
                            },
                            child: Text('Add Category'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondary,
                              foregroundColor: black,
                            ),
                          ),
                        ],
                      ),
                    if (selectedCategory == 'Accommodations')
                      Column(
                        children: [
                          TextFieldWidget(
                            label: 'Rooms Available',
                            controller: roomsAvailableController,
                            borderColor: primary,
                            hintColor: grey,
                            width: 350,
                            height: 60,
                            radius: 10,
                            hasValidator: true,
                            inputType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter rooms available'
                                : null,
                          ),
                          TextFieldWidget(
                            label: 'Total Rooms',
                            controller: totalRoomsController,
                            borderColor: primary,
                            hintColor: grey,
                            width: 350,
                            height: 60,
                            radius: 10,
                            hasValidator: true,
                            inputType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Enter total rooms'
                                : null,
                          ),
                          TextFieldWidget(
                            label: 'Room Types (comma separated)',
                            controller: roomTypesController,
                            borderColor: primary,
                            hintColor: grey,
                            width: 350,
                            height: 60,
                            radius: 10,
                            hasValidator: false,
                          ),
                          TextFieldWidget(
                            label: 'Price Range',
                            controller: priceRangeController,
                            borderColor: primary,
                            hintColor: grey,
                            width: 350,
                            height: 60,
                            radius: 10,
                            hasValidator: false,
                          ),
                        ],
                      )
                    else if (selectedCategory == 'Transportation')
                      Column(
                        children: [
                          TextFieldWidget(
                            label: 'Fares (format: type:price,type:price)',
                            controller: faresController,
                            borderColor: primary,
                            hintColor: grey,
                            width: 350,
                            height: 60,
                            radius: 10,
                            hasValidator: true,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Enter fare details';
                              if (!value.contains(':'))
                                return 'Use format: type:price';
                              return null;
                            },
                          ),
                        ],
                      )
                    else if (selectedCategory == 'Markets')
                      Column(
                        children: [
                          TextFieldWidget(
                            label:
                                'Prices (format: Category:Item=Price,Item=Price|Category:Item=Price)',
                            controller: pricesController,
                            borderColor: primary,
                            hintColor: grey,
                            width: 350,
                            height: 120,
                            radius: 10,
                            hasValidator: true,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Enter price details';
                              if (!value.contains(':'))
                                return 'Use format: Category:Item=Price';
                              return null;
                            },
                          ),
                        ],
                      ),
                    TextFieldWidget(
                      label: 'Location',
                      controller: locationController,
                      borderColor: primary,
                      hintColor: grey,
                      width: 350,
                      height: 60,
                      radius: 10,
                      hasValidator: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter location'
                          : null,
                    ),
                    TextFieldWidget(
                      label: 'Description',
                      controller: descriptionController,
                      borderColor: primary,
                      hintColor: grey,
                      width: 350,
                      height: 60,
                      radius: 10,
                      hasValidator: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter description'
                          : null,
                    ),
                    TextFieldWidget(
                      label: 'Phone',
                      controller: phoneController,
                      borderColor: primary,
                      hintColor: grey,
                      width: 350,
                      height: 60,
                      radius: 10,
                      hasValidator: false,
                    ),
                    TextFieldWidget(
                      label: 'Email',
                      controller: emailController,
                      borderColor: primary,
                      hintColor: grey,
                      width: 350,
                      height: 60,
                      radius: 10,
                      hasValidator: false,
                    ),
                    TextFieldWidget(
                      label: 'Business Hours',
                      controller: hoursController,
                      borderColor: primary,
                      hintColor: grey,
                      width: 350,
                      height: 60,
                      radius: 10,
                      hasValidator: false,
                    ),
                    // Social Media Accounts Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Social Media Accounts',
                          fontSize: 16,
                          color: black,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(height: 8),
                        TextFieldWidget(
                          label: 'TikTok',
                          controller: tiktokController,
                          borderColor: primary,
                          hintColor: grey,
                          width: 350,
                          height: 60,
                          radius: 10,
                          hasValidator: false,
                          hint: 'https://tiktok.com/@username',
                        ),
                        TextFieldWidget(
                          label: 'Facebook',
                          controller: facebookController,
                          borderColor: primary,
                          hintColor: grey,
                          width: 350,
                          height: 60,
                          radius: 10,
                          hasValidator: false,
                          hint: 'https://facebook.com/page',
                        ),
                        TextFieldWidget(
                          label: 'Instagram',
                          controller: instagramController,
                          borderColor: primary,
                          hintColor: grey,
                          width: 350,
                          height: 60,
                          radius: 10,
                          hasValidator: false,
                          hint: 'https://instagram.com/username',
                        ),
                        TextFieldWidget(
                          label: 'Telegram',
                          controller: telegramController,
                          borderColor: primary,
                          hintColor: grey,
                          width: 350,
                          height: 60,
                          radius: 10,
                          hasValidator: false,
                          hint: 'https://t.me/username',
                        ),
                      ],
                    ),
                    // Geolocation Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Geolocation',
                          fontSize: 16,
                          color: black,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Latitude',
                                controller: latitudeController,
                                borderColor: primary,
                                hintColor: grey,
                                width: 165,
                                height: 60,
                                radius: 10,
                                hasValidator: false,
                                inputType: TextInputType.numberWithOptions(
                                    decimal: true, signed: true),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Longitude',
                                controller: longitudeController,
                                borderColor: primary,
                                hintColor: grey,
                                width: 165,
                                height: 60,
                                radius: 10,
                                hasValidator: false,
                                inputType: TextInputType.numberWithOptions(
                                    decimal: true, signed: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Map for selecting location
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: primary),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: FlutterMap(
                              mapController: mapController,
                              options: MapOptions(
                                initialCenter: _selectedLocation ??
                                    const LatLng(15.7589, 121.5623),
                                initialZoom: 12.0,
                                onTap: (tapPosition, latLng) =>
                                    _handleMapTap(latLng, setState),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'autour_web',
                                ),
                                MarkerLayer(
                                  markers: [
                                    if (_selectedLocation != null)
                                      Marker(
                                        point: _selectedLocation!,
                                        width: 80,
                                        height: 80,
                                        child: Icon(
                                          Icons.location_pin,
                                          color: _getCategoryColor(
                                              selectedCategory),
                                          size: 40,
                                        ),
                                      ),
                                  ],
                                ),
                                // Add zoom controls
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: Column(
                                    children: [
                                      FloatingActionButton(
                                        mini: true,
                                        onPressed: () {
                                          mapController.move(
                                              mapController.camera.center,
                                              mapController.camera.zoom + 1);
                                        },
                                        child: Icon(Icons.add),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                      ),
                                      SizedBox(height: 5),
                                      FloatingActionButton(
                                        mini: true,
                                        onPressed: () {
                                          mapController.move(
                                              mapController.camera.center,
                                              mapController.camera.zoom - 1);
                                        },
                                        child: Icon(Icons.remove),
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedLocation = null;
                                  latitudeController.clear();
                                  longitudeController.clear();
                                });
                              },
                              child: Text('Clear Location'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Image Picker Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'Business Image',
                          fontSize: 16,
                          color: black,
                          fontFamily: 'Bold',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => _pickImage(setState),
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
                                TextWidget(
                                  text: 'Image selected: $_imageName',
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontFamily: 'Medium',
                                ),
                              ],
                            ),
                          )
                        else if (imageController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.blue, size: 16),
                                SizedBox(width: 4),
                                TextWidget(
                                  text: 'Existing image loaded',
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontFamily: 'Medium',
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: TextWidget(
                              text: 'No image selected',
                              fontSize: 12,
                              color: grey,
                              fontFamily: 'Regular',
                            ),
                          ),
                      ],
                    ),
                    // TODO: Add dynamic fields for prices and fares if needed
                  ],
                ),
              ),
            ),
          );
        }),
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
            label: business == null ? 'Add' : 'Update',
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                String? imageUrl = imageController.text;

                // Upload image if selected
                if (_webImageBytes != null) {
                  imageUrl = await _uploadImageToFirebase();
                  if (imageUrl == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Failed to upload image. Please try again.')),
                    );
                    return;
                  }
                }

                // Parse latitude and longitude
                double? latitude, longitude;
                if (latitudeController.text.isNotEmpty) {
                  latitude = double.tryParse(latitudeController.text);
                }
                if (longitudeController.text.isNotEmpty) {
                  longitude = double.tryParse(longitudeController.text);
                }

                // Parse room information and update timestamps if needed
                int? roomsAvailable =
                    int.tryParse(roomsAvailableController.text);
                int? totalRooms = int.tryParse(totalRoomsController.text);

                // Update timestamps if room information changed
                DateTime? roomAvailabilityLastUpdated =
                    business?.roomAvailabilityLastUpdated;
                DateTime? priceLastUpdated = business?.priceLastUpdated;

                // Check if room information has changed
                if (business != null &&
                    (business.roomsAvailable != roomsAvailable ||
                        business.totalRooms != totalRooms)) {
                  roomAvailabilityLastUpdated = DateTime.now();
                }

                if (business == null) {
                  addBusiness(Business(
                    name: nameController.text,
                    category: selectedCategory,
                    location: locationController.text,
                    description: descriptionController.text,
                    registrationNumber:
                        registrationNumberController.text, // New field
                    phone: phoneController.text,
                    email: emailController.text,
                    hours: hoursController.text,
                    roomsAvailable: roomsAvailable,
                    totalRooms: totalRooms,
                    roomTypes: roomTypesController.text.isNotEmpty
                        ? roomTypesController.text
                            .split(',')
                            .map((e) => e.trim())
                            .toList()
                        : null,
                    priceRange: priceRangeController.text,
                    fares: faresController.text.isNotEmpty
                        ? Map.fromEntries(faresController.text.split(',').map(
                            (e) => MapEntry(e.split(':')[0].trim(),
                                e.split(':')[1].trim())))
                        : null,
                    prices: pricesController.text.isNotEmpty
                        ? Map.fromEntries(pricesController.text
                            .split('|')
                            .map((e) => MapEntry(
                                e.split(':')[0].trim(),
                                Map.fromEntries(e.split(':')[1].split(',').map(
                                      (v) => MapEntry(v.split('=')[0].trim(),
                                          v.split('=')[1].trim()),
                                    )))))
                        : null,
                    image: imageUrl,
                    // Municipality field
                    municipality: selectedMunicipality,
                    // Social media fields
                    tiktok: tiktokController.text,
                    facebook: facebookController.text,
                    instagram: instagramController.text,
                    telegram: telegramController.text,
                    // Geolocation fields
                    latitude: latitude,
                    longitude: longitude,
                    // Timestamp fields
                    roomAvailabilityLastUpdated: roomAvailabilityLastUpdated,
                    priceLastUpdated: priceLastUpdated,
                  ));
                } else if (id != null) {
                  updateBusiness(
                      id,
                      Business(
                        name: nameController.text,
                        category: selectedCategory,
                        location: locationController.text,
                        description: descriptionController.text,
                        registrationNumber:
                            registrationNumberController.text, // New field
                        phone: phoneController.text,
                        email: emailController.text,
                        hours: hoursController.text,
                        roomsAvailable: roomsAvailable,
                        totalRooms: totalRooms,
                        roomTypes: roomTypesController.text.isNotEmpty
                            ? roomTypesController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList()
                            : null,
                        priceRange: priceRangeController.text,
                        fares: faresController.text.isNotEmpty
                            ? Map.fromEntries(faresController.text
                                .split(',')
                                .map((e) => MapEntry(e.split(':')[0].trim(),
                                    e.split(':')[1].trim())))
                            : null,
                        prices: pricesController.text.isNotEmpty
                            ? Map.fromEntries(pricesController.text
                                .split('|')
                                .map((e) => MapEntry(
                                    e.split(':')[0].trim(),
                                    Map.fromEntries(
                                        e.split(':')[1].split(',').map(
                                              (v) => MapEntry(
                                                  v.split('=')[0].trim(),
                                                  v.split('=')[1].trim()),
                                            )))))
                            : null,
                        image: imageUrl,
                        // Municipality field
                        municipality: selectedMunicipality,
                        // Social media fields
                        tiktok: tiktokController.text,
                        facebook: facebookController.text,
                        instagram: instagramController.text,
                        telegram: telegramController.text,
                        // Geolocation fields
                        latitude: latitude,
                        longitude: longitude,
                        // Timestamp fields
                        roomAvailabilityLastUpdated:
                            roomAvailabilityLastUpdated,
                        priceLastUpdated: priceLastUpdated,
                      ));
                }
                Navigator.pop(context);
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

  void _deleteBusiness(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: 'Delete Business',
          fontSize: 20,
          color: Colors.red,
          fontFamily: 'Bold',
        ),
        content: TextWidget(
          text: 'Are you sure you want to delete this business?',
          fontSize: 16,
          color: black,
          fontFamily: 'Regular',
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
            label: 'Delete',
            onPressed: () {
              deleteBusiness(id);
              Navigator.pop(context);
            },
            color: Colors.red,
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

  @override
  void initState() {
    super.initState();
    _setupFirestoreListener();
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Business> get filteredBusinesses {
    return businesses.where((business) {
      final matchesCategory =
          selectedCategory == 'All' || business.category == selectedCategory;
      final matchesMunicipality = selectedMunicipality == 'All' ||
          business.municipality == selectedMunicipality;
      final matchesSearch = business.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          business.description
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          business.location.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesMunicipality && matchesSearch;
    }).toList();
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
          text: 'Local Businesses Management',
          fontSize: 20,
          color: white,
          fontFamily: 'Bold',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(40),
        children: [
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
                  text: 'Marketplace & Business Listings',
                  fontSize: 28,
                  color: primary,
                  fontFamily: 'Bold',
                  align: TextAlign.left,
                ),
                const SizedBox(height: 12),
                TextWidget(
                  text:
                      'Showcase, edit, and analyze local businesses, accommodations, and services.',
                  fontSize: 16,
                  color: black,
                  fontFamily: 'Regular',
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
                      text: 'Businesses',
                      fontSize: 22,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_upload, size: 18),
                      label: const Text('Import CSV'),
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
                      onPressed: _importFromCSV,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.file_download, size: 18),
                      label: const Text('Export CSV'),
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
                      onPressed: _exportToCSV,
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Business'),
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
                      onPressed: () => _showBusinessDialog(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Search Bar
                TextFieldWidget(
                  label: 'Search Businesses',
                  hint: 'Search by name, location, or description',
                  controller: searchController,
                  borderColor: primary,
                  hintColor: grey,
                  width: 350,
                  height: 50,
                  radius: 8,
                  hasValidator: false,
                  inputType: TextInputType.text,
                  prefix: const Icon(Icons.search, color: grey),
                ),
                const SizedBox(height: 16),
                // Category Filters
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
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
                              text: category,
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
                const SizedBox(height: 16),
                // Municipality Filters
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: municipalities.length,
                    itemBuilder: (context, index) {
                      final municipality = municipalities[index];
                      final isSelected = selectedMunicipality == municipality;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMunicipality = municipality;
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
                              text: municipality,
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
                const SizedBox(height: 24),
                // Toggle between list and map view
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isMapView = !_isMapView;
                        });
                      },
                      icon: Icon(_isMapView ? Icons.list : Icons.map),
                      label: Text(_isMapView ? 'List View' : 'Map View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Display either list or map view
                _isMapView
                    ? _buildMapView()
                    : filteredBusinesses.isEmpty
                        ? Center(
                            child: TextWidget(
                              text: 'No businesses found.',
                              fontSize: 18,
                              color: grey,
                              fontFamily: 'Regular',
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filteredBusinesses.length,
                            itemBuilder: (context, index) {
                              final business = filteredBusinesses[index];
                              return _buildBusinessCard(
                                  business, businessIds[index]);
                            },
                          ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Build map view to display businesses
  Widget _buildMapView() {
    final MapController mapController = MapController();
    final businessesWithLocation = filteredBusinesses
        .where((business) =>
            business.latitude != null && business.longitude != null)
        .toList();

    if (businessesWithLocation.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: grey),
            const SizedBox(height: 16),
            TextWidget(
              text: 'No businesses with location data found.',
              fontSize: 18,
              color: grey,
              fontFamily: 'Regular',
            ),
            const SizedBox(height: 8),
            TextWidget(
              text:
                  'Add businesses with latitude and longitude to see them on the map.',
              fontSize: 14,
              color: grey,
              fontFamily: 'Regular',
            ),
          ],
        ),
      );
    }

    // Calculate center point for the map
    double avgLat = 0, avgLon = 0;
    for (var business in businessesWithLocation) {
      avgLat += business.latitude!;
      avgLon += business.longitude!;
    }
    avgLat /= businessesWithLocation.length;
    avgLon /= businessesWithLocation.length;

    return Container(
      height: 500,
      decoration: BoxDecoration(
        border: Border.all(color: primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(avgLat, avgLon),
            initialZoom: 12.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'autour_web',
            ),
            MarkerLayer(
              markers: businessesWithLocation.map((business) {
                return Marker(
                  point: LatLng(business.latitude!, business.longitude!),
                  width: 80,
                  height: 80,
                  child: GestureDetector(
                    onTap: () {
                      // Show business details when marker is tapped
                      _showBusinessDetailsDialog(business);
                    },
                    child: Icon(
                      Icons.location_pin,
                      color: _getCategoryColor(business.category),
                      size: 40,
                    ),
                  ),
                );
              }).toList(),
            ),
            // Add zoom controls
            Positioned(
              right: 10,
              bottom: 10,
              child: Column(
                children: [
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      mapController.move(mapController.camera.center,
                          mapController.camera.zoom + 1);
                    },
                    child: Icon(Icons.add),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  SizedBox(height: 5),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () {
                      mapController.move(mapController.camera.center,
                          mapController.camera.zoom - 1);
                    },
                    child: Icon(Icons.remove),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show business details in a dialog
  void _showBusinessDetailsDialog(Business business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: TextWidget(
          text: business.name,
          fontSize: 20,
          color: primary,
          fontFamily: 'Bold',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text:
                    '${business.category} - ${business.municipality ?? ''} - ${business.location}',
                fontSize: 14,
                color: grey,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: business.description,
                fontSize: 13,
                color: black,
                fontFamily: 'Regular',
              ),
              if (business.registrationNumber != null &&
                  business.registrationNumber!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: 'Registration: ${business.registrationNumber}',
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              if (business.phone != null && business.phone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: business.phone!,
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              if (business.email != null && business.email!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: business.email!,
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              if (business.hours != null && business.hours!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: business.hours!,
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              // Social Media Links
              if ((business.tiktok != null && business.tiktok!.isNotEmpty) ||
                  (business.facebook != null &&
                      business.facebook!.isNotEmpty) ||
                  (business.instagram != null &&
                      business.instagram!.isNotEmpty) ||
                  (business.telegram != null && business.telegram!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Social Media:',
                        fontSize: 12,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (business.tiktok != null &&
                              business.tiktok!.isNotEmpty)
                            _buildSocialMediaButton(
                                Icons.music_note, 'TikTok', business.tiktok!),
                          if (business.facebook != null &&
                              business.facebook!.isNotEmpty)
                            _buildSocialMediaButton(
                                Icons.facebook, 'Facebook', business.facebook!),
                          if (business.instagram != null &&
                              business.instagram!.isNotEmpty)
                            _buildSocialMediaButton(Icons.camera_alt,
                                'Instagram', business.instagram!),
                          if (business.telegram != null &&
                              business.telegram!.isNotEmpty)
                            _buildSocialMediaButton(
                                Icons.send, 'Telegram', business.telegram!),
                        ],
                      ),
                    ],
                  ),
                ),
              if (business.category == 'Accommodations' &&
                  business.roomsAvailable != null &&
                  business.totalRooms != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bed, color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          TextWidget(
                            text:
                                '${business.roomsAvailable}/${business.totalRooms} rooms available',
                            fontSize: 12,
                            color: Colors.blue,
                            fontFamily: 'Medium',
                          ),
                        ],
                      ),
                      if (business.roomAvailabilityLastUpdated != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: TextWidget(
                            text:
                                'Last updated: ${_formatDateTime(business.roomAvailabilityLastUpdated!)}',
                            fontSize: 10,
                            color: grey,
                            fontFamily: 'Regular',
                          ),
                        ),
                      const SizedBox(height: 4),
                      TextWidget(
                        text: 'Note: Room availability and pricing may change',
                        fontSize: 10,
                        color: Colors.orange,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              // Location with Google Maps link
              if (business.latitude != null && business.longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          TextWidget(
                            text:
                                'Coordinates: ${business.latitude!.toStringAsFixed(4)}, '
                                '${business.longitude!.toStringAsFixed(4)}',
                            fontSize: 12,
                            color: grey,
                            fontFamily: 'Regular',
                          ),
                          const SizedBox(width: 8),
                          // Google Maps link
                          IconButton(
                            icon: const Icon(Icons.map,
                                size: 16, color: Colors.blue),
                            onPressed: () {
                              final url =
                                  'https://www.google.com/maps/search/?api=1&query=${business.latitude},${business.longitude}';
                              _launchURL(url);
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: 'Click the map icon to view on Google Maps',
                        fontSize: 10,
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

  // Get color based on business category for map markers
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Accommodations':
        return Colors.blue;
      case 'Restaurants':
        return Colors.red;
      case 'Markets':
        return Colors.green;
      case 'Transportation':
        return Colors.orange;
      case 'Services':
        return Colors.purple;
      case 'Tours':
        return Colors.teal;
      default:
        return primary;
    }
  }

  // CSV Import functionality
  void _importFromCSV() {
    // Create an input element for file selection
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement()
          ..accept = '.csv'
          ..multiple = false;

    // Add a change listener to handle file selection
    uploadInput.onChange.listen((e) async {
      if (uploadInput.files!.isNotEmpty) {
        final file = uploadInput.files![0];

        // Read the file as text
        final reader = html.FileReader();
        reader.readAsText(file);

        reader.onLoadEnd.listen((e) async {
          if (reader.result != null) {
            try {
              final csvContent = reader.result as String;
              final lines = csvContent.split('\n');

              if (lines.length < 2) {
                throw Exception('CSV file is empty or invalid');
              }

              // Parse header
              final headers = lines[0].split(',').map((h) => h.trim()).toList();

              int importedCount = 0;

              // Process each line (skip header)
              for (int i = 1; i < lines.length; i++) {
                if (lines[i].trim().isEmpty) continue;

                final values =
                    lines[i].split(',').map((v) => v.trim()).toList();

                if (values.length != headers.length) {
                  print('Skipping line $i: column count mismatch');
                  continue;
                }

                // Create a map of header to value
                final Map<String, String> row = {};
                for (int j = 0; j < headers.length; j++) {
                  row[headers[j]] = values[j];
                }

                // Create business object from CSV row
                final business = Business(
                  name: row['name'] ?? '',
                  category: row['category'] ?? 'Services',
                  municipality: row['municipality'],
                  location: row['location'] ?? '',
                  description: row['description'] ?? '',
                  phone: row['phone'],
                  email: row['email'],
                  hours: row['hours'],
                  image: row['image'],
                  // Social media
                  tiktok: row['tiktok'],
                  facebook: row['facebook'],
                  instagram: row['instagram'],
                  telegram: row['telegram'],
                  // Geolocation
                  latitude:
                      row['latitude'] != null && row['latitude']!.isNotEmpty
                          ? double.tryParse(row['latitude']!)
                          : null,
                  longitude:
                      row['longitude'] != null && row['longitude']!.isNotEmpty
                          ? double.tryParse(row['longitude']!)
                          : null,
                );

                // Add to Firestore
                await addBusiness(business);
                importedCount++;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Successfully imported $importedCount businesses'),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error importing CSV: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
      }
    });

    // Trigger the file selection dialog
    uploadInput.click();
  }

  // CSV Export functionality
  void _exportToCSV() {
    try {
      // Create CSV header
      final headers = [
        'name',
        'category',
        'municipality',
        'location',
        'description',
        'phone',
        'email',
        'hours',
        'image',
        'tiktok',
        'facebook',
        'instagram',
        'telegram',
        'latitude',
        'longitude'
      ];

      // Create CSV rows
      final rows = <List<String>>[];

      for (final business in businesses) {
        rows.add([
          business.name,
          business.category,
          business.municipality ?? '',
          business.location,
          business.description,
          business.phone ?? '',
          business.email ?? '',
          business.hours ?? '',
          business.image ?? '',
          business.tiktok ?? '',
          business.facebook ?? '',
          business.instagram ?? '',
          business.telegram ?? '',
          business.latitude?.toString() ?? '',
          business.longitude?.toString() ?? '',
        ]);
      }

      // Generate CSV content
      final csvRows = [headers.join(',')];
      for (final row in rows) {
        csvRows.add(row.map((field) => '"$field"').join(','));
      }

      final csvContent = csvRows.join('\n');

      // Create download link
      final blob = html.Blob([csvContent], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'businesses_${DateTime.now().millisecondsSinceEpoch}.csv';

      html.document.body!.children.add(anchor);
      anchor.click();
      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported ${businesses.length} businesses to CSV'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildBusinessCard(Business business, String id) {
    return SizedBox(
      width: 350,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (business.image != null && business.image!.isNotEmpty)
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: primary),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          business.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.store, color: primary, size: 28),
                        ),
                      ),
                    )
                  else
                    Icon(Icons.store, color: primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextWidget(
                      text: business.name,
                      fontSize: 18,
                      color: black,
                      fontFamily: 'Bold',
                      align: TextAlign.left,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () =>
                        _showBusinessDialog(business: business, id: id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteBusiness(id),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextWidget(
                text:
                    '${business.category} - ${business.municipality ?? ''} - ${business.location}',
                fontSize: 14,
                color: grey,
                fontFamily: 'Regular',
                align: TextAlign.left,
              ),
              const SizedBox(height: 8),
              TextWidget(
                text: business.description,
                fontSize: 13,
                color: black,
                fontFamily: 'Regular',
                align: TextAlign.left,
                maxLines: 3,
              ),
              if (business.registrationNumber != null &&
                  business.registrationNumber!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number,
                          size: 16, color: Colors.blue),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: 'Reg: ${business.registrationNumber}',
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              if (business.phone != null && business.phone!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: business.phone!,
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              if (business.email != null && business.email!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: business.email!,
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              if (business.hours != null && business.hours!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: business.hours!,
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              // Social Media Links
              if ((business.tiktok != null && business.tiktok!.isNotEmpty) ||
                  (business.facebook != null &&
                      business.facebook!.isNotEmpty) ||
                  (business.instagram != null &&
                      business.instagram!.isNotEmpty) ||
                  (business.telegram != null && business.telegram!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Social Media:',
                        fontSize: 12,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (business.tiktok != null &&
                              business.tiktok!.isNotEmpty)
                            _buildSocialMediaButton(
                                Icons.music_note, 'TikTok', business.tiktok!),
                          if (business.facebook != null &&
                              business.facebook!.isNotEmpty)
                            _buildSocialMediaButton(
                                Icons.facebook, 'Facebook', business.facebook!),
                          if (business.instagram != null &&
                              business.instagram!.isNotEmpty)
                            _buildSocialMediaButton(Icons.camera_alt,
                                'Instagram', business.instagram!),
                          if (business.telegram != null &&
                              business.telegram!.isNotEmpty)
                            _buildSocialMediaButton(
                                Icons.send, 'Telegram', business.telegram!),
                        ],
                      ),
                    ],
                  ),
                ),
              if (business.category == 'Accommodations' &&
                  business.roomsAvailable != null &&
                  business.totalRooms != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bed, color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          TextWidget(
                            text:
                                '${business.roomsAvailable}/${business.totalRooms} rooms available',
                            fontSize: 12,
                            color: Colors.blue,
                            fontFamily: 'Medium',
                          ),
                        ],
                      ),
                      if (business.roomAvailabilityLastUpdated != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: TextWidget(
                            text:
                                'Last updated: ${_formatDateTime(business.roomAvailabilityLastUpdated!)}',
                            fontSize: 10,
                            color: grey,
                            fontFamily: 'Regular',
                          ),
                        ),
                      const SizedBox(height: 4),
                      TextWidget(
                        text: 'Note: Room availability and pricing may change',
                        fontSize: 10,
                        color: Colors.orange,
                        fontFamily: 'Regular',
                      ),
                    ],
                  ),
                ),
              if (business.roomTypes != null && business.roomTypes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextWidget(
                    text: 'Types: ${business.roomTypes!.join(', ')}',
                    fontSize: 11,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                ),
              if (business.priceRange != null &&
                  business.priceRange!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextWidget(
                    text: 'Price: ${business.priceRange}',
                    fontSize: 11,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                ),
              if (business.fares != null && business.fares!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextWidget(
                    text:
                        'Fares: ${business.fares!.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                    fontSize: 11,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                ),
              if (business.prices != null && business.prices!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextWidget(
                    text:
                        'Prices: ${business.prices!.entries.map((e) => '${e.key}: ${e.value.entries.map((v) => '${v.key}=${v.value}').join(',')}').join('|')}',
                    fontSize: 11,
                    color: grey,
                    fontFamily: 'Regular',
                  ),
                ),
              // Location coordinates
              if (business.latitude != null && business.longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.red),
                      const SizedBox(width: 4),
                      TextWidget(
                        text: 'Lat: ${business.latitude!.toStringAsFixed(4)}, '
                            'Lon: ${business.longitude!.toStringAsFixed(4)}',
                        fontSize: 12,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                      const SizedBox(width: 8),
                      // Google Maps link
                      IconButton(
                        icon:
                            const Icon(Icons.map, size: 16, color: Colors.blue),
                        onPressed: () {
                          final url =
                              'https://www.google.com/maps/search/?api=1&query=${business.latitude},${business.longitude}';
                          _launchURL(url);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build social media buttons
  Widget _buildSocialMediaButton(IconData icon, String name, String url) {
    return ElevatedButton.icon(
      onPressed: () {
        _launchURL(url);
      },
      icon: Icon(icon, size: 16),
      label: Text(name, style: TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: primary.withOpacity(0.1),
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  // Helper method to format DateTime
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Helper method to launch URLs
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await launchUrl(uri)) {
      // URL launched successfully
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }
}
