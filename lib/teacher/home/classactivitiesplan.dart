import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanClassActivitiesForm extends StatefulWidget {
  const PlanClassActivitiesForm({super.key});

  @override
  State<PlanClassActivitiesForm> createState() => _PlanClassActivitiesFormState();
}

class _PlanClassActivitiesFormState extends State<PlanClassActivitiesForm> {
  // Variables to hold the selected date, activity title, and description
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose(); // Dispose title controller
    _activityController.dispose(); // Dispose activity description controller
    super.dispose();
  }

  // Function to show the date picker and set the selected date
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

  // Method to save class activity details to Firestore
  Future<void> _saveClassActivity() async {
    if (_selectedDate != null && _titleController.text.isNotEmpty && _activityController.text.isNotEmpty) {
      try {
        // Add the class activity to Firestore
        await FirebaseFirestore.instance.collection('class_activities').add({
          'date': _selectedDate, // Store selected date
          'title': _titleController.text, // Store activity title
          'activity': _activityController.text, // Store activity details
          'created_at': Timestamp.now(), // Optional: Store timestamp
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Class activity planned successfully!'),
          ),
        );

        // Clear the form after submission
        setState(() {
          _selectedDate = null;
          _titleController.clear();
          _activityController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date, enter a title, and provide activity details.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title without using AppBar
        Center(
          child: Text(
            'Plan Class Activities', // Form title
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[700],
            ),
          ),
        ),
        const SizedBox(height: 30), // Space between title and form

        // Date Picker Button
        Text(
          _selectedDate == null
              ? 'No Date Selected'
              : 'Selected Date: ${DateFormat('d MMM y').format(_selectedDate!)}', // Format the date
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

        // Title Input Field
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Activity Title',
            hintText: 'Enter the title of the class activity...',
          ),
        ),
        const SizedBox(height: 20),

        // Activity Details Input Field
        TextField(
          controller: _activityController,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Plan Class Activity',
            hintText: 'Enter the details of the class activity...',
          ),
        ),
        const SizedBox(height: 20),

        // Save/Submit Button
        Center(
          child: ElevatedButton(
            onPressed: _saveClassActivity,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              backgroundColor: Colors.blueGrey,
            ),
            child: const Text(
              'Plan Activity',
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
