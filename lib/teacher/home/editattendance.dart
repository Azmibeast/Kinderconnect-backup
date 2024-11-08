import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditAttendance extends StatefulWidget {
  const EditAttendance({super.key});

  @override
  State<EditAttendance> createState() => _EditAttendanceState();
}

class _EditAttendanceState extends State<EditAttendance> {
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _attendanceRecords = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate); // Set default date format
    _fetchAttendanceRecords(); // Fetch records for the current date by default
  }

  // Function to fetch attendance records for the selected date
  Future<void> _fetchAttendanceRecords() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .where('date', isEqualTo: Timestamp.fromDate(_selectedDate))
        .get();

    setState(() {
      _attendanceRecords = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'isPresent': data['isPresent'],
          'studentId': data['studentId'],
        };
      }).toList();
    });
  }

  // Function to update attendance record in Firestore
  Future<void> _updateAttendance(String docId, bool isPresent) async {
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(docId)
        .update({'isPresent': isPresent});
  }

  // Function to delete attendance record from Firestore
  Future<void> _deleteAttendance(String docId) async {
    await FirebaseFirestore.instance
        .collection('attendance')
        .doc(docId)
        .delete();

    // Remove the deleted record from the list and update the UI
    setState(() {
      _attendanceRecords.removeWhere((record) => record['id'] == docId);
    });
  }

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
        _fetchAttendanceRecords(); // Fetch records for the new date
      });
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
      backgroundColor: Colors.white,
      body: Container(
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
        child: Column(
          children: [
            const Text(
              "Edit Attendance",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Date Picker Field
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 15),

            Expanded(
              child: _attendanceRecords.isEmpty
                  ? const Center(child: Text("No attendance records found for this date."))
                  : ListView.builder(
                      itemCount: _attendanceRecords.length,
                      itemBuilder: (context, index) {
                        final record = _attendanceRecords[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(record['name']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: record['isPresent'],
                                  onChanged: (bool value) async {
                                    setState(() {
                                      record['isPresent'] = value;
                                    });
                                    await _updateAttendance(record['id'], value);
                                  },
                                  activeColor: Colors.green,
                                  inactiveThumbColor: Colors.red,
                                  inactiveTrackColor: Colors.redAccent,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _deleteAttendance(record['id']);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Attendance record deleted")),
                                    );
                                  },
                                ),
                              ],
                            ),
                            subtitle: Text(record['isPresent'] ? "Present" : "Absent"),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
