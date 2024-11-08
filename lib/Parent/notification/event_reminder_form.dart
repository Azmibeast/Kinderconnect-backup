import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting

class EventReminderForm extends StatelessWidget {
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
          'Upcoming Events',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),

        // Fetch and display events from Firestore
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('special_event').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No upcoming events'));
              }

              // Display events in a ListView
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final event = snapshot.data!.docs[index];
                  final timestamp = event['date'] as Timestamp?;
                  final formattedDate = timestamp != null
                      ? DateFormat('d MMMM y').format(timestamp.toDate())
                      : 'No Date'; // Format timestamp to a readable date

                  return ListTile(
                    title: Text(event['title'] ?? 'No Title'),
                    subtitle: Text(
                      'Date: $formattedDate\nDescription: ${event['description'] ?? 'No Description'}',
                    ),
                  );
                },
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
