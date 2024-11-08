import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildDetailsForm extends StatefulWidget {
  final String parentId;

  const ChildDetailsForm({Key? key, required this.parentId}) : super(key: key);

  @override
  _ChildDetailsFormState createState() => _ChildDetailsFormState();
}

class _ChildDetailsFormState extends State<ChildDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _healthStatusController = TextEditingController();
  
  String? _selectedFile;
  String? _selectedChildId; // To store the selected child ID
  List<DocumentSnapshot> _children = []; // To store the list of children

  // Function to fetch children based on parentId
  Future<void> _fetchChildren() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('parent_id', isEqualTo: widget.parentId)
        .where('isApproved', isEqualTo: true) // Only include approved children
        .get();

    setState(() {
      _children = snapshot.docs;
    });
  }

  // Function to pick file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _selectedFile = result.files.single.path;
      });
    }
  }

  // Function to update child details in Firestore
  Future<void> _updateChildDetails() async {
    if (_selectedChildId != null) {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(_selectedChildId)
          .update({
        'emergencyContact': _emergencyContactController.text,
        'allergies': _allergiesController.text,
        'healthStatus': _healthStatusController.text,
        'healthDocument': _selectedFile,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchChildren();
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
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset: const Offset(0, 3), // Offset for shadow
            ),
          ],
        ),

    child: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Update Child Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown to select child
          DropdownButtonFormField<String>(
            value: _selectedChildId,
            hint: const Text('Select Child'),
            onChanged: (value) {
              setState(() {
                _selectedChildId = value;
              });
            },
            items: _children.map((child) {
              return DropdownMenuItem<String>(
                value: child.id,
                child: Text(child['name']), // Assuming child has 'name' field
              );
            }).toList(),
            validator: (value) {
              if (value == null) {
                return 'Please select a child';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Emergency Contact Field
          TextFormField(
            controller: _emergencyContactController,
            decoration: const InputDecoration(
              labelText: 'Emergency Contact Number',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter emergency contact number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Allergies Input Field
          TextFormField(
            controller: _allergiesController,
            decoration: const InputDecoration(
              labelText: 'Allergies (if any)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Health Status Input Field
          TextFormField(
            controller: _healthStatusController,
            decoration: const InputDecoration(
              labelText: 'Health Status',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // File Attachment Section for Health Documents
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.attach_file),
                  label: Text(_selectedFile == null
                      ? 'Attach Health Document'
                      : 'File: ${_selectedFile!.split('/').last}'),
                  onPressed: _pickFile,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                await _updateChildDetails();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Child details updated for: ${_children.firstWhere((child) => child.id == _selectedChildId)['name']}',
                    ),
                  ),
                );
              }
            },
            child: const Text('Update Details'),
          ),
        ],
      ),
    ),
    ),
      ),
    );
    
  }
}
