import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentProgressSection extends StatefulWidget {
  final String parentId;

  StudentProgressSection({required this.parentId});

  @override
  _StudentProgressSectionState createState() => _StudentProgressSectionState();
}

class _StudentProgressSectionState extends State<StudentProgressSection> {
  String? selectedChildId;
  String? selectedChildName;
  String? profileImageUrl;
  String? selectedExam;

  final Map<String, double> gradeToHeight = {
    'A': 5.0,
    'B': 4.0,
    'C': 3.0,
    'D': 2.0,
    'E': 1.0,
  };

  final List<String> monthNames = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Student Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('students')
                .where('parent_id', isEqualTo: widget.parentId)
                .where('isApproved', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              var childrenDocs = snapshot.data!.docs;
              return DropdownButton<String>(
                hint: const Text("Select Child"),
                value: selectedChildId,
                items: childrenDocs.map((child) {
                  return DropdownMenuItem<String>(
                    value: child.id,
                    child: Text(child['name']),
                  );
                }).toList(),
                onChanged: (childId) {
                  setState(() {
                    selectedChildId = childId;
                    selectedChildName = childrenDocs
                        .firstWhere((child) => child.id == childId)['name'];
                    profileImageUrl = childrenDocs
                        .firstWhere((child) => child.id == childId)['profile_image'];
                    selectedExam = null;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 20),
          if (selectedChildId != null) ...[
            profileImageUrl != null
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(profileImageUrl!),
                  )
                : const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/student_profile.jpg'),
                  ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('students')
                  .doc(selectedChildId)
                  .collection('progress')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                var exams = snapshot.data!.docs
                    .map((doc) => doc['exam'].toString())
                    .toSet()
                    .toList();
                return DropdownButton<String>(
                  hint: const Text("Select Exam"),
                  value: selectedExam,
                  items: exams.map((exam) {
                    return DropdownMenuItem<String>(
                      value: exam,
                      child: Text(exam),
                    );
                  }).toList(),
                  onChanged: (exam) {
                    setState(() {
                      selectedExam = exam;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedExam == null
                  ? const Center(child: Text('Select an exam to view progress.'))
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .doc(selectedChildId)
                          .collection('progress')
                          .where('exam', isEqualTo: selectedExam)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No progress data available.',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        List<BarChartGroupData> barGroups = [];
                        int index = 0;
                        for (var doc in snapshot.data!.docs) {
                          String month = doc['month'];
                          String grade = doc['grade'];
                          double? height = gradeToHeight[grade];
                          if (height != null) {
                            barGroups.add(
                              BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: height,
                                    color: Colors.blue,
                                    width: 15,
                                  ),
                                ],
                                showingTooltipIndicators: [0],
                              ),
                            );
                            index++;
                          }
                        }

                        return BarChart(
                          BarChartData(
                            barGroups: barGroups,
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    String grade = gradeToHeight.keys
                                        .firstWhere((k) => gradeToHeight[k] == value,
                                            orElse: () => '');
                                    return Text(grade);
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int monthIndex = value.toInt();
                                    return Text(monthNames[monthIndex % 12]);
                                  },
                                ),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.grey),
                            ),
                            gridData: FlGridData(show: true),
                          ),
                        );
                      },
                    ),
            ),
          ]
        ],
      ),
    ),
      ),
    );
  }
}
