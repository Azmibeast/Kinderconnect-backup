import 'package:KinderConnect/Parent/profile/attendance_details.dart';
import 'package:flutter/material.dart';
import 'class_activities_section.dart'; // Import the Class Activities Section
import 'student_progress_section.dart'; // Import the Student Progress Section

class ParentActivitiesPage extends StatefulWidget {
  final String parentId;
  const ParentActivitiesPage({Key? key, required this.parentId}) : super(key: key);

  @override
  _ParentActivitiesPageState createState() => _ParentActivitiesPageState();
}

class _ParentActivitiesPageState extends State<ParentActivitiesPage> with TickerProviderStateMixin {
  // Initialize the AnimationControllers for each tile
  List<AnimationController> _animationControllers = [];

  @override
  void initState() {
    super.initState();
    // Create animation controllers for each tile
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

  Widget _buildDashboardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AnimationController animationController,
  }) {
    // Create a scale animation
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 40.0),
        child: Column(
          children: [
            _buildSectionTitle('Parent Activities'),
            const SizedBox(height: 20),

            // Row of dashboard tiles
            _buildTileRow([
              _buildDashboardTile(
                icon: Icons.class_,
                label: 'Class Activities',
                onTap: () => _navigateToPage(ClassActivitiesSection()),
                animationController: _animationControllers[0],
              ),
              _buildDashboardTile(
                icon: Icons.show_chart,
                label: 'Student Progress',
                onTap: () => _navigateToPage(StudentProgressSection(parentId: widget.parentId)),
                animationController: _animationControllers[1],
              ),
            ]),

            const SizedBox(height: 20),

            // Single tile row for Attendance Details
            _buildTileRow([
              _buildDashboardTile(
                icon: Icons.date_range,
                label: 'Attendance Details',
                onTap: () => _navigateToPage(AttendanceDetails(parentId: widget.parentId)),
                animationController: _animationControllers[2],
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTileRow(List<Widget> tiles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: tiles,
    );
  }
}
