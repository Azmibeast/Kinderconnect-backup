import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentFeedbackForm extends StatefulWidget {
  @override
  _ParentFeedbackFormState createState() => _ParentFeedbackFormState();
}

class _ParentFeedbackFormState extends State<ParentFeedbackForm> {
  final TextEditingController _feedbackController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  // Toggle like status of a feedback item
  void _toggleLike(DocumentSnapshot feedbackDoc) async {
    final currentLiked = feedbackDoc['liked'] ?? false;
    final currentLikes = feedbackDoc['likes'] ?? 0;

    await FirebaseFirestore.instance
        .collection('feedbacks')
        .doc(feedbackDoc.id)
        .update({
      'liked': !currentLiked,
      'likes': currentLiked ? currentLikes - 1 : currentLikes + 1,
    });
  }

  // Function to add new feedback to Firestore
  void _submitFeedback() async {
    if (_feedbackController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        'name': 'Anonymous', // Assuming the current user is "Anonymous"
        'feedback': _feedbackController.text,
        'liked': false,
        'likes': 0,
        'approved': false, // Requires teacher's approval
        'replied': false, // Initial state for replied status
        'reply': '', // Initialize reply field
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your feedback!')),
      );
      _feedbackController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
    }
  }

  // Function to add a comment to a feedback item
  void _submitComment(String feedbackId) async {
    if (_commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(feedbackId)
          .collection('comments')
          .add({
        'comment': _commentController.text,
        'parentName': 'Anonymous', // Assuming current user is "Anonymous"
        'approved': false, // Requires teacher's approval
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment submitted for approval')),
      );
      _commentController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your comment')),
      );
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
      body: SingleChildScrollView(
        child: Container(
          height: 600,
    margin: const EdgeInsets.fromLTRB(30.0, 5.0, 30.0, 70.0),
    padding: const EdgeInsets.all(25.0),
    decoration: BoxDecoration(
      color: Colors.white, // Background color
      borderRadius: BorderRadius.circular(10), // Rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5), // Shadow color
          spreadRadius: 2, // Spread radius
          blurRadius: 5, // Blur radius
          offset: const Offset(0, 3), // Offset for shadow
        ),
      ],
    ),

    child: Column(
      children: [
        const Text(
          'Parent Feedback',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Display Feedback List from Firestore
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('feedbacks')
                .where('approved', isEqualTo: true) // Only approved feedback
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No approved feedback available'));
              }

              // Display each feedback with comments, reply, and likes
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final feedbackDoc = snapshot.data!.docs[index];
                  return ListTile(
                    title: Text(feedbackDoc['name'] ?? 'Anonymous'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(feedbackDoc['feedback'] ?? 'No Feedback'),
                        const SizedBox(height: 5),
                        if (feedbackDoc['replied'] == true && feedbackDoc['reply'] != '')
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
                            color: Colors.blue.withOpacity(0.1),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Teacher\'s Reply:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(feedbackDoc['reply']),
                              ],
                            ),
                          ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('feedbacks')
                              .doc(feedbackDoc.id)
                              .collection('comments')
                              .where('approved', isEqualTo: true)
                              .snapshots(),
                          builder: (context, commentSnapshot) {
                            if (!commentSnapshot.hasData ||
                                commentSnapshot.data!.docs.isEmpty) {
                              return const Text('No comments yet');
                            }
                            return Column(
                              children: commentSnapshot.data!.docs.map((comment) {
                                return ListTile(
                                  title: Text(comment['parentName'] ?? 'Anonymous'),
                                  subtitle: Text(comment['comment'] ?? 'No Comment'),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            feedbackDoc['liked'] ? Icons.favorite : Icons.favorite_border,
                            color: feedbackDoc['liked'] ? Colors.red : Colors.grey,
                          ),
                          onPressed: () => _toggleLike(feedbackDoc),
                        ),
                        Text('${feedbackDoc['likes']}'),
                        IconButton(
                          icon: const Icon(Icons.comment),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Add Comment'),
                                  content: TextField(
                                    controller: _commentController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your comment',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        _submitComment(feedbackDoc.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Submit'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Feedback Input Field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: TextFormField(
            controller: _feedbackController,
            decoration: const InputDecoration(
              labelText: 'Add your feedback',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Submit Feedback Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ElevatedButton(
            onPressed: _submitFeedback,
            child: const Text('Submit Feedback'),
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
        ),
      ),
    );
  }
}
