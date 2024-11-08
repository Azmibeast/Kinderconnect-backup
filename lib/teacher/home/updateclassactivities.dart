import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ClassActivitiesSection extends StatefulWidget {
  @override
  _ClassActivitiesSectionState createState() => _ClassActivitiesSectionState();
}

class _ClassActivitiesSectionState extends State<ClassActivitiesSection> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _deleteActivity(String activityId) async {
    await FirebaseFirestore.instance.collection('class_activities').doc(activityId).delete();
  }

  Future<void> _uploadImages(String activityId) async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      List<String> imageUrls = [];

      for (var pickedFile in pickedFiles) {
        final File file = File(pickedFile.path);
        final ref = FirebaseStorage.instance
            .ref()
            .child('class_activities')
            .child(activityId)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await ref.putFile(file);
        final imageUrl = await ref.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      await FirebaseFirestore.instance.collection('class_activities').doc(activityId).update({
        'imageUrls': FieldValue.arrayUnion(imageUrls),
      });
    }
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day + 1);
    final malaysiaTimeOffset = const Duration(hours: 8);

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
      body: SingleChildScrollView(
        child: Container(
          height: 700,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Class Activities',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('class_activities')
                      .orderBy('date', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const CircularProgressIndicator();

                    final activities = snapshot.data!.docs;
                    final previousActivities = activities.where((activity) {
                      final activityDate =
                          (activity['date'] as Timestamp).toDate().add(malaysiaTimeOffset);
                      return activityDate.isBefore(todayEnd);
                    }).toList();

                    final upcomingActivities = activities.where((activity) {
                      final activityDate =
                          (activity['date'] as Timestamp).toDate().add(malaysiaTimeOffset);
                      return activityDate.isAfter(todayEnd);
                    }).toList();

                    return Column(
                      children: [
                        // Previous Activities Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Previous Activities',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              previousActivities.isNotEmpty
                                  ? Expanded(
                                      child: ListView.builder(
                                        itemCount: previousActivities.length,
                                        itemBuilder: (context, index) {
                                          final activity = previousActivities[index];
                                          final activityTitle = activity['title'];
                                          final activityId = activity.id;
                                          final activityDate = (activity['date'] as Timestamp)
                                              .toDate()
                                              .add(malaysiaTimeOffset);
                                          final formattedDate = DateFormat('dd-MM-yyyy').format(activityDate);
                                          final imageUrls = (activity.data() as Map<String, dynamic>)
                                                  .containsKey('imageUrls')
                                              ? List<String>.from(activity['imageUrls'])
                                              : [];

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$activityTitle - $formattedDate',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: imageUrls.isNotEmpty
                                                          ? imageUrls.map((imageUrl) {
                                                              return GestureDetector(
                                                                onTap: () => _showImagePreview(
                                                                    context, imageUrl),
                                                                child: Image.network(
                                                                  imageUrl,
                                                                  width: 100,
                                                                  height: 100,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              );
                                                            }).toList()
                                                          : [
                                                              const Text(
                                                                'No picture available.',
                                                                style: TextStyle(color: Colors.red),
                                                              ),
                                                            ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  ElevatedButton(
                                                    onPressed: () => _uploadImages(activityId),
                                                    child: const Icon(Icons.add_a_photo),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () => _deleteActivity(activityId),
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : const Text(
                                      'No previous activities.',
                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                              const Divider(color: Colors.black),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Upcoming Activities Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Upcoming Activities',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              upcomingActivities.isNotEmpty
                                  ? Expanded(
                                      child: ListView.builder(
                                        itemCount: upcomingActivities.length,
                                        itemBuilder: (context, index) {
                                          final activity = upcomingActivities[index];
                                          final activityTitle = activity['title'];
                                          final activityId = activity.id;
                                          final activityDate = (activity['date'] as Timestamp)
                                              .toDate()
                                              .add(malaysiaTimeOffset);
                                          final formattedDate = DateFormat('dd-MM-yyyy').format(activityDate);
                                          final imageUrls = (activity.data() as Map<String, dynamic>)
                                                  .containsKey('imageUrls')
                                              ? List<String>.from(activity['imageUrls'])
                                              : [];

                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$activityTitle - $formattedDate',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: imageUrls.isNotEmpty
                                                          ? imageUrls.map((imageUrl) {
                                                              return GestureDetector(
                                                                onTap: () => _showImagePreview(
                                                                    context, imageUrl),
                                                                child: Image.network(
                                                                  imageUrl,
                                                                  width: 100,
                                                                  height: 100,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              );
                                                            }).toList()
                                                          : [
                                                              const Text(
                                                                'No picture available.',
                                                                style: TextStyle(color: Colors.red),
                                                              ),
                                                            ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () => _deleteActivity(activityId),
                                                  ),
                                                ],
                                              ),
                                              const Divider(),
                                            ],
                                          );
                                        },
                                      ),
                                    )
                                  : const Text(
                                      'No upcoming activities.',
                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                            ],
                          ),
                        ),
                      ],
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
