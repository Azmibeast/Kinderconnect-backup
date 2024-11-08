import 'package:KinderConnect/teacher/notification/attendancenotification.dart';
import 'package:KinderConnect/teacher/notification/newstudentnotification.dart';
import 'package:KinderConnect/teacher/notification/teacherfeedback.dart';
import 'package:flutter/material.dart';

class TeacherReminderPage extends StatefulWidget {
  const TeacherReminderPage({super.key});

  @override
  State<TeacherReminderPage> createState() => _TeacherReminderPageState();
}

class _TeacherReminderPageState extends State<TeacherReminderPage> with TickerProviderStateMixin {
  // List to hold the controllers for each dashboard tile
  List<AnimationController> _animationControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize AnimationControllers for each tile
    for (int i = 0; i < 3; i++) {
      _animationControllers.add(AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ));
    }
  }

  @override
  void dispose() {
    // Dispose all AnimationControllers
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildSectionTitle('Reminders'),
            const SizedBox(height: 20),
            // First Row with two tiles
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDashboardTile(
                  icon: Icons.feedback_outlined,
                  label: 'Feedback Notifications',
                  onTap: () => _navigateToPage(const TeacherFeedbackSection()),
                  animationController: _animationControllers[0],
                ),
                _buildDashboardTile(
                  icon: Icons.notifications_active_outlined,
                  label: 'Absent Notifications',
                  onTap: () => _navigateToPage(const AbsentNotification()),
                  animationController: _animationControllers[1],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Second Row with single tile centered
            Center(
              child: _buildDashboardTile(
                icon: Icons.person_add_alt_outlined,
                label: 'New Student Application',
                onTap: () => _navigateToPage(const NewStudentNotification()),
                animationController: _animationControllers[2],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDashboardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AnimationController animationController,
  }) {
    Animation<double> scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );

    return GestureDetector(
      onTapDown: (_) => animationController.forward(),
      onTapUp: (_) {
        animationController.reverse();
        onTap(); // Call the onTap function
      },
      onTapCancel: () => animationController.reverse(),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          width: 150, // Set a fixed width to align the tiles
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 218, 222, 212),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: const Color.fromARGB(255, 77, 147, 68)),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
