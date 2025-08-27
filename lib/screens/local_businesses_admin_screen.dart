import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'package:autour_web/widgets/textfield_widget.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class Business {
  String name;
  String category;
  String location;
  String description;
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

  Business({
    required this.name,
    required this.category,
    required this.location,
    required this.description,
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
  });
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

  String selectedCategory = 'All';
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<Business> businesses = [];
  List<String> businessIds = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _setupFirestoreListener() {
    businessesRef.snapshots().listen((snapshot) {
      setState(() {
        businesses = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Business(
            name: data['name'],
            category: data['category'],
            location: data['location'],
            description: data['description'],
            phone: data['phone'],
            email: data['email'],
            hours: data['hours'],
            roomsAvailable: data['roomsAvailable'],
            totalRooms: data['totalRooms'],
            roomTypes: data['roomTypes']?.cast<String>(),
            priceRange: data['priceRange'],
            prices: data['prices']?.cast<String, dynamic>(),
            fares: data['fares']?.cast<String, dynamic>(),
            image: data['image'],
          );
        }).toList();
        businessIds = snapshot.docs.map((doc) => doc.id).toList();
      });
    });
  }

  Future<void> addBusiness(Business business) async {
    await businessesRef.add({
      'name': business.name,
      'category': business.category,
      'location': business.location,
      'description': business.description,
      'phone': business.phone,
      'email': business.email,
      'hours': business.hours,
      'roomsAvailable': business.roomsAvailable,
      'totalRooms': business.totalRooms,
      'roomTypes': business.roomTypes,
      'priceRange': business.priceRange,
      'prices': business.prices,
      'fares': business.fares,
      'image': business.image,
    });
  }

  Future<void> updateBusiness(String id, Business business) async {
    await businessesRef.doc(id).update({
      'name': business.name,
      'category': business.category,
      'location': business.location,
      'description': business.description,
      'phone': business.phone,
      'email': business.email,
      'hours': business.hours,
      'roomsAvailable': business.roomsAvailable,
      'totalRooms': business.totalRooms,
      'roomTypes': business.roomTypes,
      'priceRange': business.priceRange,
      'prices': business.prices,
      'fares': business.fares,
      'image': business.image,
    });
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

  void _showBusinessDialog({Business? business, String? id}) {
    final nameController = TextEditingController(text: business?.name ?? '');
    String selectedCategory = business?.category ??
        categories[1]; // Default to first non-'All' category
    final locationController =
        TextEditingController(text: business?.location ?? '');
    final descriptionController =
        TextEditingController(text: business?.description ?? '');
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
    final formKey = GlobalKey<FormState>();
    String? _uploadedImageUrl;
    Uint8List? _webImageBytes;
    String? _imageName;

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
                    TextFieldWidget(
                      label: 'Business Name',
                      controller: nameController,
                      borderColor: primary,
                      hintColor: grey,
                      width: 350,
                      height: 60,
                      radius: 10,
                      hasValidator: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter business name'
                          : null,
                    ),
                    SizedBox(
                      height: 10,
                    ),
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

                if (business == null) {
                  addBusiness(Business(
                    name: nameController.text,
                    category: selectedCategory,
                    location: locationController.text,
                    description: descriptionController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                    hours: hoursController.text,
                    roomsAvailable: int.tryParse(roomsAvailableController.text),
                    totalRooms: int.tryParse(totalRoomsController.text),
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
                  ));
                } else if (id != null) {
                  updateBusiness(
                      id,
                      Business(
                        name: nameController.text,
                        category: selectedCategory,
                        location: locationController.text,
                        description: descriptionController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                        hours: hoursController.text,
                        roomsAvailable:
                            int.tryParse(roomsAvailableController.text),
                        totalRooms: int.tryParse(totalRoomsController.text),
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
      final matchesSearch = business.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          business.description
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          business.location.toLowerCase().contains(searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
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
                const SizedBox(height: 24),
                filteredBusinesses.isEmpty
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
                text: '${business.category} - ${business.location}',
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
              if (business.category == 'Accommodations' &&
                  business.roomsAvailable != null &&
                  business.totalRooms != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
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
            ],
          ),
        ),
      ),
    );
  }
}
