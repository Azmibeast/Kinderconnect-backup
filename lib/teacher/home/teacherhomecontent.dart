import 'package:KinderConnect/teacher/home/classactivitiesplan.dart';
import 'package:KinderConnect/teacher/home/editattendance.dart';
import 'package:KinderConnect/teacher/home/editspecialevent.dart';
import 'package:KinderConnect/teacher/home/specialeventplan.dart';
import 'package:KinderConnect/teacher/home/updateclassactivities.dart';
import 'package:KinderConnect/teacher/home/validateattendanceform.dart';
import 'package:KinderConnect/teacher/notification/teacherriminder.dart';
import 'package:KinderConnect/teacher/profile/teacherclassactivities.dart';
import 'package:KinderConnect/welcome.dart';
import 'package:flutter/material.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [
    const TeacherActivitiesPage(),
    const TeacherHomeContent(),
    const TeacherReminderPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.blueGrey,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notification',
          ),
        ],
      ),
    );
  }
}

class TeacherHomeContent extends StatefulWidget {
  const TeacherHomeContent({Key? key}) : super(key: key);

  @override
  _TeacherHomeContentState createState() => _TeacherHomeContentState();
}

class _TeacherHomeContentState extends State<TeacherHomeContent> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // List to hold the controllers for each dashboard tile
  List<AnimationController> _animationControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationControllers for each tile
    for (int i = 0; i < 6; i++) {
      _animationControllers.add(AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ));
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all AnimationControllers
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateToPage(int pageIndex, Widget page) {
    setState(() {
      _currentPage = pageIndex;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      setState(() {}); // Refresh the page indicator when returning
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 40.0),
            child: Column(
              children: [
                _buildSectionTitle('Attendance'),
                _buildTileRow([
                  _buildDashboardTile(
                    icon: Icons.check_circle_outline,
                    label: 'Validate Attendance',
                    onTap: () => _navigateToPage(0, const ValidateAttendanceForm()),
                    animationController: _animationControllers[0],
                  ),
                  _buildDashboardTile(
                    icon: Icons.edit_document,
                    label: 'Edit Attendance',
                    onTap: () => _navigateToPage(1, const EditAttendance()),
                    animationController: _animationControllers[1],
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSectionTitle('Class Activities'),
                _buildTileRow([
                  _buildDashboardTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Plan Class Activities',
                    onTap: () => _navigateToPage(2, const PlanClassActivitiesForm()),
                    animationController: _animationControllers[2],
                  ),
                  _buildDashboardTile(
                    icon: Icons.edit_outlined,
                    label: 'Edit Class Activity',
                    onTap: () => _navigateToPage(3, ClassActivitiesSection()),
                    animationController: _animationControllers[3],
                  ),
                ]),
                const SizedBox(height: 20),
                _buildSectionTitle('Special Events'),
                _buildTileRow([
                  _buildDashboardTile(
                    icon: Icons.event,
                    label: 'Plan Special Event',
                    onTap: () => _navigateToPage(4, const PlanSpecialEventForm()),
                    animationController: _animationControllers[4],
                  ),
                  _buildDashboardTile(
                    icon: Icons.edit_calendar_outlined,
                    label: 'Edit Special Event',
                    onTap: () => _navigateToPage(5, const EditSpecialEvent()),
                    animationController: _animationControllers[5],
                  ),
                ]),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Welcome()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
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

  Widget _buildDashboardTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AnimationController animationController,
  }) {
    // Create a Scale animation
    Animation<double> scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeIn,
      ),
    );

    return GestureDetector(
      onTapDown: (_) {
        animationController.forward();
      },
      onTapUp: (_) {
        animationController.reverse();
        onTap(); // Call the onTap function
      },
      onTapCancel: () {
        animationController.reverse();
      },
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 218, 222, 212),
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
              Icon(icon, size: 40, color: Color.fromARGB(255, 77, 147, 68)),
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
