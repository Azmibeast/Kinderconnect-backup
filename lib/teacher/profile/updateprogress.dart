import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateStudentProgress extends StatefulWidget {
  const UpdateStudentProgress({super.key});

  @override
  State<UpdateStudentProgress> createState() => _UpdateStudentProgressState();
}

class _UpdateStudentProgressState extends State<UpdateStudentProgress> {
  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  String? _selectedMonth;
  String? _selectedStudent;
  final TextEditingController _examController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();

  @override
  void dispose() {
    _examController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  Future<void> _addStudentProgress() async {
    if (_selectedMonth != null &&
        _selectedStudent != null &&
        _examController.text.isNotEmpty &&
        _gradeController.text.isNotEmpty) {
      
      await FirebaseFirestore.instance
          .collection('students')
          .doc(_selectedStudent)
          .collection('progress')
          .add({
        'month': _selectedMonth,
        'exam': _examController.text,
        'grade': _gradeController.text,
      });

      _examController.clear();
      _gradeController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  Future<void> _updateProgress(String docId) async {
    if (_selectedMonth != null &&
        _examController.text.isNotEmpty &&
        _gradeController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('students')
          .doc(_selectedStudent)
          .collection('progress')
          .doc(docId)
          .update({
        'month': _selectedMonth,
        'exam': _examController.text,
        'grade': _gradeController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progress updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  Future<void> _deleteProgress(String docId) async {
    await FirebaseFirestore.instance
        .collection('students')
        .doc(_selectedStudent)
        .collection('progress')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress deleted successfully')),
    );
  }

  void _showEditDialog(String docId, String exam, String grade, String month) {
    _examController.text = exam;
    _gradeController.text = grade;
    _selectedMonth = month;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Month',
                  border: OutlineInputBorder(),
                ),
                value: _selectedMonth,
                items: _months.map((month) {
                  return DropdownMenuItem(
                    value: month,
                    child: Text(month),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _examController,
                decoration: const InputDecoration(
                  labelText: 'Exam Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _gradeController,
                decoration: const InputDecoration(
                  labelText: 'Grade',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateProgress(docId);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
        margin: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 20.0),
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8.0,
              spreadRadius: 2.0,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Student Progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 24.0),
            StreamBuilder<QuerySnapshot>( 
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .where('isApproved', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final students = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Approved Student',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedStudent,
                  items: students.map((student) {
                    return DropdownMenuItem(
                      value: student.id,
                      child: Text(student['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStudent = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Select Month',
                border: OutlineInputBorder(),
              ),
              value: _selectedMonth,
              items: _months.map((month) {
                return DropdownMenuItem(
                  value: month,
                  child: Text(month),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _examController,
              decoration: const InputDecoration(
                labelText: 'Enter Exam Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _gradeController,
              decoration: const InputDecoration(
                labelText: 'Enter Grade',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _addStudentProgress,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                child: const Text(
                  'Add Progress',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container( // Changed from Expanded to Container
              height: 300, // Set a fixed height
              child: _selectedStudent != null
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .doc(_selectedStudent)
                          .collection('progress')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final progressDocs = snapshot.data!.docs;

                        if (progressDocs.isEmpty) {
                          return const Center(child: Text('No progress added yet.'));
                        }

                        return ListView.builder(
                          itemCount: progressDocs.length,
                          itemBuilder: (context, index) {
                            final progressData = progressDocs[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.green),
                                title: Text('${progressData['exam']} - ${progressData['grade']}'),
                                subtitle: Text('${progressData['month']}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showEditDialog(
                                        progressData.id,
                                        progressData['exam'],
                                        progressData['grade'],
                                        progressData['month'],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteProgress(progressData.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : const Center(child: Text('Please select a student.')),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
