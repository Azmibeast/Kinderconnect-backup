import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceDetails extends StatefulWidget {
  final String parentId;
  AttendanceDetails({required this.parentId});

  @override
  State<AttendanceDetails> createState() => _AttendanceDetailsState();
}

class _AttendanceDetailsState extends State<AttendanceDetails> {
  String? _selectedChildId;
  List<DocumentSnapshot> _children = [];

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  // Fetch the list of children for the parent from Firestore
  Future<void> _fetchChildren() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('parent_id', isEqualTo: widget.parentId)
        .where('isApproved', isEqualTo: true)
        .get();

    setState(() {
      _children = snapshot.docs;
      if (_children.isNotEmpty) {
        _selectedChildId = _children.first.id; // Set the default selected child
      }
    });

    // Debugging: Print child names to verify data
    print("Fetched children:");
    for (var child in _children) {
      print(child['name']);
    }
  }

  // Fetch attendance records for the selected child from Firestore
  Future<List<DocumentSnapshot>> _fetchAttendanceRecords() async {
    if (_selectedChildId == null) {
      return [];
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('studentId', isEqualTo: _selectedChildId)
        .get();

    return snapshot.docs;
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
      height: 550,
      width: 400,
      margin: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 30.0),
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
      child: 
      
      
      Column(
        children: [
          // Normal title
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Attendance Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Dropdown to select a child
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _selectedChildId,
              hint: const Text('Select Child'),
              items: _children.map((child) {
                return DropdownMenuItem<String>(
                  value: child.id,
                  child: Text(child['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedChildId = value;
                });
              },
            ),
          ),

          // Display attendance records
          Expanded(
            child: FutureBuilder<List<DocumentSnapshot>>(
              future: _fetchAttendanceRecords(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading attendance records.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No attendance records found.'));
                }

                final attendanceRecords = snapshot.data!;
                return ListView.builder(
                  itemCount: attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final record = attendanceRecords[index];
                    final date = (record['date'] as Timestamp).toDate();
                    final formattedDate = DateFormat('dd-MM-yyyy').format(date);

                    return ListTile(
                      title: Text('Date: $formattedDate'),
                      subtitle: Text(
                        record['isPresent'] ? 'Present' : 'Absent',
                        style: TextStyle(
                          color: record['isPresent'] ? Colors.green : Colors.red,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}
