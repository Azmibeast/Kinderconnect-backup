import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ValidateAttendanceForm extends StatefulWidget {
  const ValidateAttendanceForm({Key? key}) : super(key: key);

  @override
  _ValidateAttendanceFormState createState() => _ValidateAttendanceFormState();
}

class _ValidateAttendanceFormState extends State<ValidateAttendanceForm> {
  List<Student> _students = [];
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Default to current date

  @override
  void initState() {
    super.initState();
    _fetchApprovedStudents();
    _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate); // Set default date format
  }

  // Function to fetch only approved students from Firestore
  Future<void> _fetchApprovedStudents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('isApproved', isEqualTo: true)
        .get();

    setState(() {
      _students = snapshot.docs
          .map((doc) => Student(
                id: doc.id,
                name: doc['name'],
                isPresent: true,
              ))
          .toList();
    });
  }

  // Function to store attendance details in Firestore
  Future<void> _storeAttendance() async {
    final batch = FirebaseFirestore.instance.batch();
    final attendanceCollection = FirebaseFirestore.instance.collection('attendance');

    for (var student in _students) {
      final docRef = attendanceCollection.doc();
      batch.set(docRef, {
        'studentId': student.id,
        'name': student.name,
        'isPresent': student.isPresent,
        'date': _selectedDate, // Include selected date
        'timestamp': Timestamp.now(),
      });
    }

    await batch.commit();
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
        _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate); // Update the date controller
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
            Navigator.of(context).pop(); // Go back to the previous page
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
        child: Stack( // Use Stack to overlay FloatingActionButton
          children: [
            Column(
              children: [
                const Text(
                  "Validate Attendance",
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
                  child: ListView.builder(
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(student.name),
                          trailing: Switch(
                            value: student.isPresent,
                            onChanged: (bool value) {
                              setState(() {
                                student.isPresent = value;
                              });
                            },
                            activeColor: Colors.green,
                            inactiveThumbColor: Colors.red,
                            inactiveTrackColor: Colors.redAccent,
                          ),
                          subtitle: Text(student.isPresent ? "Present" : "Absent"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // FloatingActionButton placed at the bottom right of the container
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                backgroundColor: Color.fromARGB(255, 39, 193, 101),
                onPressed: () async {
                  await _storeAttendance();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Attendance validated and saved!")),
                  );
                },
                child: const Icon(Icons.check),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for students
class Student {
  String id;
  String name;
  bool isPresent;

  Student({required this.id, required this.name, this.isPresent = true});
}
