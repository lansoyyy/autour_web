import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/app_text_form_field.dart';
import 'package:autour_web/widgets/button_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ContactManagementScreen extends StatefulWidget {
  const ContactManagementScreen({super.key});

  @override
  State<ContactManagementScreen> createState() =>
      _ContactManagementScreenState();
}

class _ContactManagementScreenState extends State<ContactManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _agencyNameController = TextEditingController();
  final _emergencyNumberController = TextEditingController();
  final _emergencyDetailsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _agencyNameController.dispose();
    _emergencyNumberController.dispose();
    _emergencyDetailsController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('emergency_contacts').add({
        'agencyName': _agencyNameController.text.trim(),
        'emergencyNumber': _emergencyNumberController.text.trim(),
        'emergencyDetails': _emergencyDetailsController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Emergency contact saved successfully!',
          backgroundColor: Colors.green,
        );
        _clearForm();
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error saving contact: $e',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _agencyNameController.clear();
    _emergencyNumberController.clear();
    _emergencyDetailsController.clear();
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
          text: 'Emergency Contact Management',
          fontSize: 22,
          color: white,
          fontFamily: 'Bold',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Add New Emergency Contact',
                        fontSize: 20,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 24),
                      AppTextFormField(
                        controller: _agencyNameController,
                        labelText: 'Agency Name',
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter agency name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextFormField(
                        controller: _emergencyNumberController,
                        labelText: 'Emergency Contact Number',
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter emergency contact number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextFormField(
                        controller: _emergencyDetailsController,
                        labelText: 'Emergency Contact Details',
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter emergency contact details';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ButtonWidget(
                            label: 'Clear',
                            onPressed: _clearForm,
                            color: Colors.grey,
                            textColor: white,
                            width: 100,
                            height: 45,
                            fontSize: 16,
                            radius: 10,
                          ),
                          const SizedBox(width: 16),
                          ButtonWidget(
                            label: 'Save Contact',
                            onPressed: _isLoading ? () {} : _saveContact,
                            color: primary,
                            textColor: white,
                            width: 150,
                            height: 45,
                            fontSize: 16,
                            radius: 10,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Saved Emergency Contacts',
                      fontSize: 20,
                      color: primary,
                      fontFamily: 'Bold',
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('emergency_contacts')
                          .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: TextWidget(
                              text: 'Error loading contacts: ${snapshot.error}',
                              fontSize: 16,
                              color: Colors.red,
                              fontFamily: 'Medium',
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: TextWidget(
                              text: 'No emergency contacts found',
                              fontSize: 16,
                              color: Colors.grey,
                              fontFamily: 'Medium',
                            ),
                          );
                        }

                        final contacts = snapshot.data!.docs;
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: contacts.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            final data = contact.data() as Map<String, dynamic>;
                            return ListTile(
                              title: TextWidget(
                                text: data['agencyName'] ?? 'Unknown Agency',
                                fontSize: 18,
                                color: black,
                                fontFamily: 'Bold',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: data['emergencyNumber'] ?? '',
                                    fontSize: 16,
                                    color: primary,
                                    fontFamily: 'Medium',
                                  ),
                                  const SizedBox(height: 4),
                                  TextWidget(
                                    text: data['emergencyDetails'] ?? '',
                                    fontSize: 14,
                                    color: black,
                                    fontFamily: 'Regular',
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await contact.reference.delete();
                                    if (mounted) {
                                      Fluttertoast.showToast(
                                        msg: 'Contact deleted successfully',
                                        backgroundColor: Colors.green,
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      Fluttertoast.showToast(
                                        msg: 'Error deleting contact: $e',
                                        backgroundColor: Colors.red,
                                      );
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
