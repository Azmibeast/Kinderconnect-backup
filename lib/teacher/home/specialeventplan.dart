import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the selected date
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

class PlanSpecialEventForm extends StatefulWidget {
  const PlanSpecialEventForm({super.key});

  @override
  State<PlanSpecialEventForm> createState() => _PlanSpecialEventFormState();
}

class _PlanSpecialEventFormState extends State<PlanSpecialEventForm> {
  // Controllers to capture event title and description
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();

  DateTime? _selectedDate; // Variable to hold the selected date

  @override
  void dispose() {
    // Clean up controllers when the widget is disposed
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  // Function to show the date picker and set the selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022), // Set earliest date (e.g., 2022)
      lastDate: DateTime(2025), // Set latest date (e.g., 2025)
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Method to save special event details to Firestore
  Future<void> _saveSpecialEvent() async {
    if (_selectedDate != null && _eventTitleController.text.isNotEmpty && _eventDescriptionController.text.isNotEmpty) {
      try {
        // Add the special event to Firestore
        await FirebaseFirestore.instance.collection('special_event').add({
          'date': _selectedDate, // Store selected date
          'title': _eventTitleController.text, // Store event title
          'description': _eventDescriptionController.text, // Store event description
          'created_at': Timestamp.now(), // Optional: Store timestamp
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Special event planned successfully!'),
          ),
        );

        // Clear the form after submission
        setState(() {
          _selectedDate = null;
          _eventTitleController.clear();
          _eventDescriptionController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date, enter a title, and provide a description.'),
        ),
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
            Navigator.of(context).pop(); // Go back to the previous page
          },
        ),
      ),
      backgroundColor: Colors.white,
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
          spreadRadius: 5,
          blurRadius: 7,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form Title
        Center(
          child: Text(
            'Plan Special Event',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[700],
            ),
          ),
        ),
        const SizedBox(height: 30), // Space between title and form

        // Date Picker
        Text(
          _selectedDate == null
              ? 'No Date Selected'
              : 'Selected Date: ${DateFormat('d MMM y').format(_selectedDate!)}',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _selectDate(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
          ),
          child: const Text(
            'Choose Date',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Event Title Input Field
        TextField(
          controller: _eventTitleController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Event Title',
            hintText: 'Enter the title of the special event',
          ),
        ),
        const SizedBox(height: 20),

        // Event Description Input Field
        TextField(
          controller: _eventDescriptionController,
          maxLines: 4,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Event Description',
            hintText: 'Enter a description for the special event',
          ),
        ),
        const SizedBox(height: 20),

        // Save/Submit Button
        Center(
          child: ElevatedButton(
            onPressed: _saveSpecialEvent,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text(
              'Plan Event',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),

    );
  }
}
