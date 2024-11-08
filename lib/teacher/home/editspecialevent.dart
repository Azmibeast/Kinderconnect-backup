import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditSpecialEvent extends StatefulWidget {
  const EditSpecialEvent({super.key});

  @override
  State<EditSpecialEvent> createState() => _EditSpecialEventState();
}

class _EditSpecialEventState extends State<EditSpecialEvent> {
  DateTime? _selectedDate;
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _updateEvent(String eventId) async {
    if (_eventTitleController.text.isNotEmpty &&
        _eventDescriptionController.text.isNotEmpty &&
        _selectedDate != null) {
      await FirebaseFirestore.instance.collection('special_event').doc(eventId).update({
        'title': _eventTitleController.text,
        'description': _eventDescriptionController.text,
        'date': _selectedDate,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event updated successfully')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all fields')));
    }
  }

  Future<void> _deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('special_event').doc(eventId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted successfully')));
  }

  Future<void> _openEditDialog(BuildContext context, DocumentSnapshot eventDoc) async {
    _eventTitleController.text = eventDoc['title'];
    _eventDescriptionController.text = eventDoc['description'];
    _selectedDate = (eventDoc['date'] as Timestamp).toDate();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _eventTitleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _eventDescriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Event Description'),
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedDate == null
                      ? 'No Date Selected'
                      : 'Selected Date: ${DateFormat('d MMM y').format(_selectedDate!)}',
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Choose Date'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _updateEvent(eventDoc.id),
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
                'Edit Special Events',
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
                  stream: FirebaseFirestore.instance.collection('special_event').orderBy('date').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No events available.'));
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((eventDoc) {
                        DateTime eventDate = (eventDoc['date'] as Timestamp).toDate();
                        bool isPastEvent = eventDate.isBefore(DateTime.now());

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(eventDoc['title']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date: ${DateFormat('d MMM y').format(eventDate)}'),
                                Text('Description: ${eventDoc['description']}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: isPastEvent
                                      ? null
                                      : () => _openEditDialog(context, eventDoc),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteEvent(eventDoc.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
