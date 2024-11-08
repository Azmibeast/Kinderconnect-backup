import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AbsentNotification extends StatefulWidget {
  const AbsentNotification({super.key});

  @override
  State<AbsentNotification> createState() => _AbsentNotificationState();
}

class _AbsentNotificationState extends State<AbsentNotification> {
  List<String> deletedAbsences = [];

  void validateAbsence(String docId) async {
    await FirebaseFirestore.instance
        .collection('absent_notice')
        .doc(docId)
        .update({'isValidated': true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Absence validated')),
    );
  }

  void deleteAbsence(String docId) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deleting notice...'),
        duration: Duration(seconds: 1),
      ),
    );

    await FirebaseFirestore.instance
        .collection('absent_notice')
        .doc(docId)
        .delete();

    setState(() {
      deletedAbsences.add(docId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Absence notice deleted'),
          ],
        ),
      ),
    );
  }

  Future<String> getStudentName(String childId) async {
    try {
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(childId)
          .get();
      return studentSnapshot['name'] ?? 'Unknown Name';
    } catch (e) {
      print('Error fetching student name: $e');
      return 'Unknown Name';
    }
  }

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd-MM-yyyy').format(timestamp.toDate());
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
                  'Absent Students Notification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('absent_notice').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No absences reported.'));
                  }

                  final absentStudents = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: absentStudents.length,
                    itemBuilder: (context, index) {
                      final studentData = absentStudents[index];
                      final childId = studentData['childId'];
                      final isDeleted = deletedAbsences.contains(studentData.id);

                      return AnimatedOpacity(
                        opacity: isDeleted ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 500),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          elevation: 3,
                          child: FutureBuilder<String>(
                            future: getStudentName(childId),
                            builder: (context, nameSnapshot) {
                              if (!nameSnapshot.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              return ListTile(
                                
                                title: Text(nameSnapshot.data ?? 'Unknown Name'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Reason: ${studentData['attendanceStatus']}'),
                                    Text('Date: ${formatDate(studentData['date'])}'),
                                    TextButton.icon(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Opening ${studentData['attachment']}')),
                                        );
                                      },
                                      icon: const Icon(Icons.attach_file),
                                      label: Text(studentData['attachment']),
                                    ),
                                  ],
                                ),
                                trailing: studentData['isValidated']
                                    ? Row(
                                        
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Validated', style: TextStyle(color: Colors.green)),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              deleteAbsence(studentData.id);
                                            },
                                          ),
                                        ],
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          validateAbsence(studentData.id);
                                        },
                                        child: const Text('Validate'),
                                      ),
                              );
                            },
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
