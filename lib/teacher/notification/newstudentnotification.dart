import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NewStudentNotification extends StatefulWidget {
  const NewStudentNotification({Key? key}) : super(key: key);

  @override
  State<NewStudentNotification> createState() => _NewStudentNotificationState();
}

class _NewStudentNotificationState extends State<NewStudentNotification> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Approve student function to update the approval status in Firestore
  Future<void> approveStudent(String studentId) async {
    await _firestore.collection('students').doc(studentId).update({
      'isApproved': true,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student application approved')),
    );
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
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'New Student Applications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('students')
                    .where('isApproved', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No new student applications.'),
                    );
                  }

                  final newStudents = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: newStudents.length,
                    itemBuilder: (context, index) {
                      final student = newStudents[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        elevation: 3,
                        child: ListTile(
                          title: Text(student['name']),
                          subtitle: Text('Date of birth: ${student['date_of_birth']}'),
                          trailing: ElevatedButton(
                            onPressed: () => approveStudent(student.id),
                            child: const Text('Approve'),
                          ),
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
    );
  }
}
