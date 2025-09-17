import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:autour_web/utils/colors.dart';
import 'package:autour_web/widgets/text_widget.dart';
import 'package:autour_web/widgets/button_widget.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 2,
        foregroundColor: white,
        title: TextWidget(
          text: 'User Management',
          fontSize: 22,
          color: white,
          fontFamily: 'Bold',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'User Management',
                    fontSize: 24,
                    color: primary,
                    fontFamily: 'Bold',
                  ),
                  ButtonWidget(
                    label: 'Add New User',
                    onPressed: () {
                      _showAddUserDialog(context);
                    },
                    color: primary,
                    textColor: white,
                    width: 150,
                    height: 45,
                    fontSize: 16,
                    radius: 10,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextWidget(
                text: 'User Analytics',
                fontSize: 24,
                color: primary,
                fontFamily: 'Bold',
              ),
              const SizedBox(height: 20),
              // Analytics Cards
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: TextWidget(
                        text: 'Error loading analytics: ${snapshot.error}',
                        fontSize: 16,
                        color: Colors.red,
                        fontFamily: 'Medium',
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? const [];
                  return _buildAnalyticsSection(docs);
                },
              ),
              const SizedBox(height: 30),
              TextWidget(
                text: 'Registered Users',
                fontSize: 24,
                color: primary,
                fontFamily: 'Bold',
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: TextWidget(
                        text: 'Error loading users: ${snapshot.error}',
                        fontSize: 16,
                        color: Colors.red,
                        fontFamily: 'Medium',
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return Center(
                      child: TextWidget(
                        text: 'No users found',
                        fontSize: 16,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor:
                          MaterialStateProperty.all(primary.withOpacity(0.1)),
                      columns: const [
                        DataColumn(
                          label: Text('Name'),
                        ),
                        DataColumn(
                          label: Text('Email'),
                        ),
                        DataColumn(
                          label: Text('Phone'),
                        ),
                        DataColumn(
                          label: Text('Nationality'),
                        ),
                        DataColumn(
                          label: Text('Address'),
                        ),
                        DataColumn(
                          label: Text('Actions'),
                        ),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data();
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(data['fullName'] ?? 'N/A'),
                            ),
                            DataCell(
                              Text(data['email'] ?? 'N/A'),
                            ),
                            DataCell(
                              Text(data['mobile'] ?? 'N/A'),
                            ),
                            DataCell(
                              Text(data['nationality'] ?? 'N/A'),
                            ),
                            DataCell(
                              Text(data['address'] ?? 'N/A'),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  ButtonWidget(
                                    label: 'View Details',
                                    onPressed: () {
                                      _showUserDetails(context, data);
                                    },
                                    color: primary,
                                    textColor: white,
                                    width: 100,
                                    height: 35,
                                    fontSize: 14,
                                    radius: 8,
                                  ),
                                  const SizedBox(width: 10),
                                  ButtonWidget(
                                    label: 'Edit',
                                    onPressed: () {
                                      _showEditUserDialog(context, doc);
                                    },
                                    color: Colors.orange,
                                    textColor: white,
                                    width: 80,
                                    height: 35,
                                    fontSize: 14,
                                    radius: 8,
                                  ),
                                  const SizedBox(width: 10),
                                  ButtonWidget(
                                    label: 'Delete',
                                    onPressed: () {
                                      _deleteUser(context, doc);
                                    },
                                    color: Colors.red,
                                    textColor: white,
                                    width: 80,
                                    height: 35,
                                    fontSize: 14,
                                    radius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              TextWidget(
                text: 'Admin Users',
                fontSize: 24,
                color: primary,
                fontFamily: 'Bold',
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream:
                    FirebaseFirestore.instance.collection('admins').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: TextWidget(
                        text: 'Error loading admins: ${snapshot.error}',
                        fontSize: 16,
                        color: Colors.red,
                        fontFamily: 'Medium',
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? const [];
                  if (docs.isEmpty) {
                    return Center(
                      child: TextWidget(
                        text: 'No admins found',
                        fontSize: 16,
                        color: grey,
                        fontFamily: 'Regular',
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor:
                          MaterialStateProperty.all(primary.withOpacity(0.1)),
                      columns: const [
                        DataColumn(
                          label: Text('Name'),
                        ),
                        DataColumn(
                          label: Text('Email'),
                        ),
                        DataColumn(
                          label: Text('Role'),
                        ),
                        DataColumn(
                          label: Text('Status'),
                        ),
                        DataColumn(
                          label: Text('Actions'),
                        ),
                      ],
                      rows: docs.map((doc) {
                        final data = doc.data();
                        final status = data['status'] ?? 'Active';
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(data['fullName'] ?? 'N/A'),
                            ),
                            DataCell(
                              Text(data['email'] ?? 'N/A'),
                            ),
                            DataCell(
                              Text(data['role'] ?? 'N/A'),
                            ),
                            DataCell(
                              Text(status),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  ButtonWidget(
                                    label: 'View Details',
                                    onPressed: () {
                                      _showAdminDetails(context, doc);
                                    },
                                    color: primary,
                                    textColor: white,
                                    width: 100,
                                    height: 35,
                                    fontSize: 14,
                                    radius: 8,
                                  ),
                                  const SizedBox(width: 10),
                                  ButtonWidget(
                                    label: status == 'Active'
                                        ? 'Deactivate'
                                        : 'Activate',
                                    onPressed: () {
                                      _toggleAdminStatus(
                                          context, doc.id, status);
                                    },
                                    color: status == 'Active'
                                        ? Colors.red
                                        : Colors.green,
                                    textColor: white,
                                    width: 100,
                                    height: 35,
                                    fontSize: 14,
                                    radius: 8,
                                  ),
                                  const SizedBox(width: 10),
                                  ButtonWidget(
                                    label: 'Change Password',
                                    onPressed: () {
                                      _showChangePasswordDialog(context, doc);
                                    },
                                    color: Colors.blue,
                                    textColor: white,
                                    width: 120,
                                    height: 35,
                                    fontSize: 14,
                                    radius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    // Calculate analytics
    final nationalityCount = <String, int>{};
    final ageGroups = {'<18': 0, '18-25': 0, '26-35': 0, '36-50': 0, '>50': 0};
    int totalUsers = docs.length;

    for (var doc in docs) {
      final data = doc.data();

      // Nationality analytics
      final nationality = data['nationality'] ?? 'Unknown';
      nationalityCount[nationality] = (nationalityCount[nationality] ?? 0) + 1;

      // Age analytics
      final dob = data['dob'];
      if (dob != null) {
        try {
          final birthDate = DateTime.parse(dob);
          final age = DateTime.now().year - birthDate.year;
          if (age < 18) {
            ageGroups['<18'] = ageGroups['<18']! + 1;
          } else if (age >= 18 && age <= 25) {
            ageGroups['18-25'] = ageGroups['18-25']! + 1;
          } else if (age >= 26 && age <= 35) {
            ageGroups['26-35'] = ageGroups['26-35']! + 1;
          } else if (age >= 36 && age <= 50) {
            ageGroups['36-50'] = ageGroups['36-50']! + 1;
          } else {
            ageGroups['>50'] = ageGroups['>50']! + 1;
          }
        } catch (e) {
          // Handle parsing errors
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard(
                    'Total Users', totalUsers.toString(), Icons.group),
                _buildSummaryCard('Nationalities',
                    nationalityCount.length.toString(), Icons.flag),
                _buildSummaryCard('Avg. Age',
                    _calculateAverageAge(docs).toStringAsFixed(1), Icons.cake),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Charts Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nationality Distribution
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Nationality Distribution',
                        fontSize: 18,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: _buildBarChart(nationalityCount, totalUsers),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Age Distribution
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Age Distribution',
                        fontSize: 18,
                        color: primary,
                        fontFamily: 'Bold',
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: _buildBarChart(ageGroups, totalUsers),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primary, size: 30),
        ),
        const SizedBox(height: 10),
        TextWidget(
          text: value,
          fontSize: 24,
          color: primary,
          fontFamily: 'Bold',
        ),
        TextWidget(
          text: title,
          fontSize: 14,
          color: grey,
          fontFamily: 'Regular',
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, int> data, int total) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final sortedData = Map.fromEntries(
        data.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

    final maxValue = sortedData.values.reduce((a, b) => a > b ? a : b);

    return CustomScrollView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = sortedData.entries.elementAt(index);
              final percentage = total > 0 ? (entry.value / total) * 100 : 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          entry.key,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                          '${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxValue > 0 ? entry.value / maxValue : 0,
                      backgroundColor: grey.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
            childCount: sortedData.length,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalBarChart(Map<String, int> data, int total) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);

    return Row(
      children: data.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total) * 100 : 0;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: maxValue > 0 ? entry.value / maxValue : 0,
                    backgroundColor: grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _getGenderColor(entry.key)),
                    minHeight: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getGenderColor(String gender) {
    switch (gender) {
      case 'Male':
        return Colors.blue;
      case 'Female':
        return Colors.pink;
      case 'Other':
        return Colors.purple;
      default:
        return primary;
    }
  }

  double _calculateAverageAge(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    int totalAge = 0;
    int validDobCount = 0;

    for (var doc in docs) {
      final data = doc.data();
      final dob = data['dob'];
      if (dob != null) {
        try {
          final birthDate = DateTime.parse(dob);
          final age = DateTime.now().year - birthDate.year;
          totalAge += age;
          validDobCount++;
        } catch (e) {
          // Handle parsing errors
        }
      }
    }

    return validDobCount > 0 ? totalAge / validDobCount : 0;
  }

  // Function to show admin details in a dialog
  void _showAdminDetails(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> adminDoc) {
    final data = adminDoc.data()!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Admin Details',
            fontSize: 22,
            color: primary,
            fontFamily: 'Bold',
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Full Name', data['fullName']),
                _buildDetailRow('Email', data['email']),
                _buildDetailRow('Mobile', data['mobile']),
                _buildDetailRow('Username', data['username']),
                _buildDetailRow('Role', data['role']),
                _buildDetailRow('Status', data['status'] ?? 'Active'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Function to toggle admin status
  Future<void> _toggleAdminStatus(
      BuildContext context, String docId, String currentStatus) async {
    try {
      final newStatus = currentStatus == 'Active' ? 'Inactive' : 'Active';
      await FirebaseFirestore.instance.collection('admins').doc(docId).update({
        'status': newStatus,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating admin status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Function to show user details in a dialog
  void _showUserDetails(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget(
            text: 'User Details',
            fontSize: 22,
            color: primary,
            fontFamily: 'Bold',
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Full Name', userData['fullName']),
                _buildDetailRow('Email', userData['email']),
                _buildDetailRow('Phone', userData['mobile']),
                _buildDetailRow('Nationality', userData['nationality']),
                _buildDetailRow('Date of Birth', userData['dob']),
                _buildDetailRow('Gender', userData['gender']),
                _buildDetailRow('Address', userData['address']),
                _buildDetailRow(
                    'Emergency Contact', userData['emergencyContact']),
                _buildDetailRow(
                    'Medical Conditions', userData['medicalConditions']),
                _buildDetailRow('Allergies', userData['allergies']),
                _buildDetailRow('Blood Type', userData['bloodType']),
                _buildDetailRow(
                    'Insurance Provider', userData['insuranceProvider']),
                _buildDetailRow('Policy Number', userData['policyNumber']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: label,
            fontSize: 14,
            color: primary,
            fontFamily: 'Bold',
          ),
          const SizedBox(height: 4),
          TextWidget(
            text: value?.toString() ?? 'N/A',
            fontSize: 16,
            color: black,
            fontFamily: 'Regular',
          ),
          const Divider(),
        ],
      ),
    );
  }

  // Function to show add user dialog
  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddUserDialog();
      },
    );
  }

  // Function to show edit user dialog
  void _showEditUserDialog(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> userDoc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditUserDialog(userDoc: userDoc);
      },
    );
  }

  // Function to show change password dialog
  void _showChangePasswordDialog(
      BuildContext context, DocumentSnapshot<Map<String, dynamic>> adminDoc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ChangePasswordDialog(adminDoc: adminDoc);
      },
    );
  }

  // Function to delete a user
  Future<void> _deleteUser(BuildContext context,
      DocumentSnapshot<Map<String, dynamic>> userDoc) async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TextWidget(
            text: 'Confirm Delete',
            fontSize: 22,
            color: primary,
            fontFamily: 'Bold',
          ),
          content: TextWidget(
            text:
                'Are you sure you want to delete this user? This action cannot be undone.',
            fontSize: 16,
            color: black,
            fontFamily: 'Regular',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion
    if (confirm == true) {
      try {
        // Delete user from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .delete();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

// Edit User Dialog Widget
class EditUserDialog extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> userDoc;

  const EditUserDialog({super.key, required this.userDoc});

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _addressController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.userDoc.data()!;
    _fullNameController = TextEditingController(text: data['fullName'] ?? '');
    _emailController = TextEditingController(text: data['email'] ?? '');
    _mobileController = TextEditingController(text: data['mobile'] ?? '');
    _nationalityController =
        TextEditingController(text: data['nationality'] ?? '');
    _addressController = TextEditingController(text: data['address'] ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _nationalityController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update user in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userDoc.id)
          .update({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'nationality': _nationalityController.text.trim(),
        'address': _addressController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': 'Active',
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user: $e'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextWidget(
        text: 'Edit User',
        fontSize: 22,
        color: primary,
        fontFamily: 'Bold',
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Mobile Field
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Nationality Field
              TextFormField(
                controller: _nationalityController,
                decoration: const InputDecoration(
                  labelText: 'Nationality',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter nationality';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(120, 40),
                    ),
                    child: Text(_isLoading ? 'Updating...' : 'Update User'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add User Dialog Widget
class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Tourism';
  bool _isLoading = false;

  final List<String> _roles = [
    'Tourism',
    'Police',
    'Barangay',
    'MDRRMO',
    ' Business'
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Add user to Firestore
      await FirebaseFirestore.instance.collection('admins').add({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': _selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding user: $e'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextWidget(
        text: 'Add Admin User',
        fontSize: 22,
        color: primary,
        fontFamily: 'Bold',
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Mobile Field
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(120, 40),
                    ),
                    child: Text(_isLoading ? 'Adding...' : 'Add User'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Change Password Dialog Widget
class ChangePasswordDialog extends StatefulWidget {
  final DocumentSnapshot<Map<String, dynamic>> adminDoc;

  const ChangePasswordDialog({super.key, required this.adminDoc});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update admin password in Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.adminDoc.id)
          .update({
        'password': _newPasswordController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing password: $e'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    final adminData = widget.adminDoc.data()!;
    final adminName = adminData['fullName'] ?? 'Admin User';

    return AlertDialog(
      title: TextWidget(
        text: 'Change Password',
        fontSize: 22,
        color: primary,
        fontFamily: 'Bold',
      ),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextWidget(
                text: 'Changing password for: $adminName',
                fontSize: 16,
                color: grey,
                fontFamily: 'Regular',
              ),
              const SizedBox(height: 20),
              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureNewPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _submitForm(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(120, 40),
                    ),
                    child: Text(_isLoading ? 'Changing...' : 'Change Password'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
