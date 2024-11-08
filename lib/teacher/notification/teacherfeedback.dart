import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherFeedbackSection extends StatefulWidget {
  const TeacherFeedbackSection({super.key});

  @override
  State<TeacherFeedbackSection> createState() => _TeacherFeedbackSectionState();
}

class _TeacherFeedbackSectionState extends State<TeacherFeedbackSection> {
  final CollectionReference feedbackCollection =
      FirebaseFirestore.instance.collection('feedbacks');

  // List of TextEditingControllers for replies, one for each feedback item
  List<TextEditingController> _replyControllers = [];

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _replyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _approveFeedback(String feedbackId) async {
    await feedbackCollection.doc(feedbackId).update({'approved': true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback approved')),
    );
  }

  Future<void> _replyToFeedback(String feedbackId, int index) async {
    String replyText = _replyControllers[index].text;
    if (replyText.isNotEmpty) {
      await feedbackCollection.doc(feedbackId).update({
        'replied': true,
        'reply': replyText,
      });
      setState(() {
        _replyControllers[index].clear(); // Clear the input field
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply sent')),
      );
    }
  }

  Future<void> _deleteFeedback(String feedbackId, int index) async {
    try {
      // Fetch comments to delete them first
      QuerySnapshot commentsSnapshot = await feedbackCollection
          .doc(feedbackId)
          .collection('comments')
          .get();

      // Create a batch to delete all comments
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var comment in commentsSnapshot.docs) {
        batch.delete(comment.reference); // Delete each comment
      }

      // Commit the batch delete
      await batch.commit();

      // Now delete the feedback document
      await feedbackCollection.doc(feedbackId).delete();

      setState(() {
        _replyControllers.removeAt(index); // Remove corresponding controller
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback and associated comments deleted')),
      );
    } catch (e) {
      // Handle any errors that occur during deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting feedback: $e')),
      );
    }
  }

  Future<void> _approveComment(String feedbackId, String commentId) async {
    await feedbackCollection
        .doc(feedbackId)
        .collection('comments')
        .doc(commentId)
        .update({'approved': true});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment approved')),
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
                  'Feedback',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[700],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              StreamBuilder<QuerySnapshot>(
                stream: feedbackCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No feedback available.'));
                  }

                  final feedbackDocs = snapshot.data!.docs;

                  // Initialize reply controllers for each feedback item
                  _replyControllers = List.generate(feedbackDocs.length, (index) => TextEditingController());

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: feedbackDocs.length,
                    itemBuilder: (context, index) {
                      var feedbackData = feedbackDocs[index];
                      String feedbackId = feedbackData.id;
                      String feedbackText = feedbackData['feedback'];
                      bool approved = feedbackData['approved'] ?? false;
                      bool liked = feedbackData['liked'] ?? false;
                      int likes = feedbackData['likes'] ?? 0;
                      bool replied = feedbackData['replied'] ?? false;
                      String reply = feedbackData['reply'] ?? '';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(feedbackData['name'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text(feedbackText),
                              const SizedBox(height: 5),
                              Text(
                                approved ? 'Approved' : 'Pending Approval',
                                style: TextStyle(
                                  color: approved ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      liked ? Icons.favorite : Icons.favorite_border,
                                      color: liked ? Colors.red : Colors.grey,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('feedbacks')
                                          .doc(feedbackId)
                                          .update({
                                        'liked': !liked,
                                        'likes': liked ? likes - 1 : likes + 1,
                                      });
                                    },
                                  ),
                                  Text('$likes', style: const TextStyle(fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                                    onPressed: () => _deleteFeedback(feedbackId, index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                    onPressed: approved ? null : () => _approveFeedback(feedbackId),
                                  ),
                                ],
                              ),
                              if (replied)
                                Text(
                                  'Teacher Reply: $reply',
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                              if (!replied)
                                TextField(
                                  controller: _replyControllers[index],
                                  decoration: InputDecoration(
                                    hintText: 'Type your reply here...',
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.send),
                                      onPressed: () => _replyToFeedback(feedbackId, index),
                                    ),
                                  ),
                                ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('feedbacks')
                                    .doc(feedbackId)
                                    .collection('comments')
                                    .snapshots(),
                                builder: (context, commentSnapshot) {
                                  if (!commentSnapshot.hasData || commentSnapshot.data!.docs.isEmpty) {
                                    return const Text('No comments yet');
                                  }
                                  return Column(
                                    children: commentSnapshot.data!.docs.map((comment) {
                                      String commentId = comment.id;
                                      String parentName = comment['parentName'] ?? 'Parent';
                                      String commentText = comment['comment'] ?? 'No Comment';
                                      bool commentApproved = comment['approved'] ?? false;

                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        child: ListTile(
                                          title: Text(parentName),
                                          subtitle: Text(commentText),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.check_circle, color: Colors.green),
                                            onPressed: commentApproved
                                                ? null
                                                : () => _approveComment(feedbackId, commentId),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
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
