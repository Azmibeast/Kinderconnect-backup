import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceForm extends StatefulWidget {
  final String parentId;

  const AttendanceForm({Key? key, required this.parentId}) : super(key: key);

  @override
  _AttendanceFormState createState() => _AttendanceFormState();
}

class _AttendanceFormState extends State<AttendanceForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  String? _attendanceStatus;
  String? _selectedChildId;
  String? _selectedFileName;
  PlatformFile? _attachedFile;

  List<Map<String, dynamic>> _childrenList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('Parent ID: ${widget.parentId}');
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('parent_id', isEqualTo: widget.parentId)
          .where('isApproved', isEqualTo: true)
          .get();

      print('Fetched children: ${snapshot.docs.length}');

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _childrenList = snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              'name': doc['name'] ?? 'Unnamed Child',
            };
          }).toList();

          _selectedChildId = _childrenList.first['id'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching children: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _attachedFile = result.files.first;
        _selectedFileName = _attachedFile!.name;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _attendanceStatus != null) {
      try {
        await FirebaseFirestore.instance.collection('absent_notice').add({
          'childId': _selectedChildId,
          'date': _selectedDate,
          'attendanceStatus': _attendanceStatus,
          'attachment': _attachedFile?.name ?? 'No attachment',
          'isValidated': false,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Absence notice has been issued to the teacher'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
    }
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
                'Notify Absence',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),

              // Child Name Dropdown
              _isLoading
                  ? CircularProgressIndicator()
                  : _childrenList.isNotEmpty
                      ? DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Child',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedChildId,
                          items: _childrenList.map((child) {
                            return DropdownMenuItem<String>(
                              value: child['id'],
                              child: Text(child['name']),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedChildId = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a child';
                            }
                            return null;
                          },
                        )
                      : const Text('No children found for this parent'),
              const SizedBox(height: 20),

              // Date Picker Field
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : 'Selected: ${_selectedDate!.toLocal()}'.split(' ')[0],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Dropdown for Attendance Status
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Reason for Absence',
                  border: OutlineInputBorder(),
                ),
                value: _attendanceStatus,
                items: const [
                  DropdownMenuItem(
                    value: 'Sick',
                    child: Text('Sick'),
                  ),
                  DropdownMenuItem(
                    value: 'Family Emergency',
                    child: Text('Family Emergency'),
                  ),
                  DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _attendanceStatus = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // File Attachment Section
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Attach File'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedFileName ?? 'No file selected',
                      style: TextStyle(
                        color: _selectedFileName != null ? Colors.green : Colors.red,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitAttendance,
                child: const Text('Notify Absence'),
              ),
            ],
          ),
        ),
        ),
        
      ),
    );
  }
}
