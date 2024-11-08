import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:intl/intl.dart';

class ClassActivitiesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    // Malaysia time offset
    final malaysiaTimeOffset = const Duration(hours: 8);
    final dateFormat = DateFormat('dd-MM-yyyy');

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
          height: 650, // Adjusted height to make the box shorter
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Class Activities',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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

                    // Separate previous and upcoming activities, adjusting for Malaysia timezone
                    final previousActivities = activities.where((activity) {
                      final activityDate = (activity['date'] as Timestamp)
                          .toDate()
                          .add(malaysiaTimeOffset);
                      return activityDate.isBefore(todayEnd);
                    }).toList();

                    final upcomingActivities = activities.where((activity) {
                      final activityDate = (activity['date'] as Timestamp)
                          .toDate()
                          .add(malaysiaTimeOffset);
                      return activityDate.isAfter(todayEnd);
                    }).toList();

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Previous Activities',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (previousActivities.isNotEmpty) ...[
                            ...previousActivities.map((activity) {
                              final activityTitle = activity['title'] ?? 'No Title';
                              final activityDate = (activity['date'] as Timestamp)
                                  .toDate()
                                  .add(malaysiaTimeOffset);
                              final formattedDate = dateFormat.format(activityDate);
                              
                              // Check if imageUrls field exists and is not null
                              final imageUrls = (activity.data() as Map<String, dynamic>).containsKey('imageUrls')
                                  ? List<String>.from(activity['imageUrls'] ?? [])
                                  : [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$activityTitle - $formattedDate',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  if (imageUrls.isNotEmpty)
                                    SizedBox(
                                      height: 150,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: imageUrls.length,
                                        itemBuilder: (context, index) {
                                          final imageUrl = imageUrls[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ImageGalleryScreen(
                                                    images: List<String>.from(imageUrls), // Ensure it is List<String>
                                                    initialIndex: index,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Image.network(
                                                imageUrl,
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    const Text('No pictures available for this activity.'),
                                  const Divider(),
                                ],
                              );
                            }).toList(),
                          ] else
                            const Text(
                              'No previous activities.',
                              style: TextStyle(fontSize: 16),
                            ),
                          const SizedBox(height: 20),
                          const Divider(color: Colors.black),
                          const SizedBox(height: 10),
                          const Text(
                            'Upcoming Activities',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          if (upcomingActivities.isNotEmpty) ...[
                            ...upcomingActivities.map((activity) {
                              final activityTitle = activity['title'] ?? 'No Title';
                              final activityDate = (activity['date'] as Timestamp)
                                  .toDate()
                                  .add(malaysiaTimeOffset);
                              final formattedDate = dateFormat.format(activityDate);
                              
                              // Check if imageUrls field exists and is not null
                              final imageUrls = (activity.data() as Map<String, dynamic>).containsKey('imageUrls')
                                  ? List<String>.from(activity['imageUrls'] ?? [])
                                  : [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$activityTitle - $formattedDate',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  if (imageUrls.isNotEmpty)
                                    SizedBox(
                                      height: 150,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: imageUrls.length,
                                        itemBuilder: (context, index) {
                                          final imageUrl = imageUrls[index];
                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ImageGalleryScreen(
                                                    images: List<String>.from(imageUrls), // Ensure it is List<String>
                                                    initialIndex: index,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 5),
                                              child: Image.network(
                                                imageUrl,
                                                width: 150,
                                                height: 150,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  else
                                    const Text('No pictures available for this activity.'),
                                  const Divider(),
                                ],
                              );
                            }).toList(),
                          ] else
                            const Text(
                              'No upcoming activities.',
                              style: TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
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

class ImageGalleryScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryScreen({Key? key, required this.images, required this.initialIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Images'),
      ),
      body: PhotoViewGallery.builder(
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        pageController: PageController(initialPage: initialIndex),
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(color: Colors.black),
      ),
    );
  }
}
