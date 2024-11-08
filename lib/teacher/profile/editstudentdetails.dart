import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditStudentDetailsSection extends StatefulWidget {
  const EditStudentDetailsSection({super.key});

  @override
  State<EditStudentDetailsSection> createState() => _EditStudentDetailsSectionState();
}

class _EditStudentDetailsSectionState extends State<EditStudentDetailsSection> {
  String? _selectedStudentId; // To store the selected student ID
  Map<String, dynamic>? _selectedStudent; // To store selected student details

  // Controller for health status input
  final TextEditingController _healthStatusController = TextEditingController();

  @override
  void dispose() {
    _healthStatusController.dispose();
    super.dispose();
  }

  // Method to save updated health status
  void _saveHealthStatus() {
    if (_selectedStudentId != null) {
      // Update Firestore with the new health status
      FirebaseFirestore.instance.collection('students').doc(_selectedStudentId).update({
        'healthStatus': _healthStatusController.text,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Health status updated successfully')),
        );
        _fetchStudentDetails(_selectedStudentId!); // Refresh the details
      });
    }
  }

  // Method to fetch student details from Firestore
  void _fetchStudentDetails(String studentId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('students').doc(studentId).get();
    setState(() {
      _selectedStudent = snapshot.data() as Map<String, dynamic>?; // Store student details
      _healthStatusController.text = _selectedStudent?['healthStatus'] ?? ''; // Initialize health status
    });
  }

  // Method to fetch all approved students from Firestore
  Future<List<Map<String, dynamic>>> _fetchApprovedStudents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('isApproved', isEqualTo: true) // Assuming 'isApproved' field indicates approval
        .get();

    return snapshot.docs.map((doc) => {
      'id': doc.id,
      'name': doc['name'],
      'profile_image': doc['profile_image'], // Assuming this is the field for the image URL
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 70.0),
          padding: const EdgeInsets.all(25.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchApprovedStudents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No approved students found.'));
              }

              final approvedStudents = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom Title
                  Center(
                    child: const Text(
                      'Edit Student Details',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(height: 30), // Space between title and form

                  // Dropdown for selecting student
                  Center(
                    child: DropdownButton<String>(
                      hint: const Text('Select a student'),
                      value: _selectedStudentId,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStudentId = newValue;
                          _fetchStudentDetails(newValue!); // Fetch student details
                        });
                      },
                      items: approvedStudents.map<DropdownMenuItem<String>>((student) {
                        return DropdownMenuItem<String>(
                          value: student['id'],
                          child: Text(student['name']),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Display student details only if a student is selected
                  if (_selectedStudent != null) ...[
                    // Profile Image
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedStudent!['profile_image'] != null && _selectedStudent!['profile_image'].isNotEmpty
                            ? NetworkImage(_selectedStudent!['profile_image']) // Load image from URL
                            : null, // Set to null if image is not available
                        child: _selectedStudent!['profile_image'] == null || _selectedStudent!['profile_image'].isEmpty
                            ? const Icon(Icons.person, size: 50) // Default icon if image fails to load
                            : null, // No icon if image is available
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Student Details
                    Text('Name: ${_selectedStudent!['name']}', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8.0),
                    Text('Birthday: ${_selectedStudent!['date_of_birth']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8.0),
                    Text('Gender: ${_selectedStudent!['gender']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8.0),
                    Text('Address: ${_selectedStudent!['address']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8.0),
                    Text('Emergency Contact: ${_selectedStudent!['emergencyContact']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8.0),
                    Text('Allergic Food: ${_selectedStudent!['allergies']}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 8.0),

                    // Health Status
                    const Text('Health Status:', style: TextStyle(fontSize: 18)),
                    TextField(
                      controller: _healthStatusController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter health status',
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Button to save health status
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveHealthStatus,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                        child: const Text(
                          'Update Health Status',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
