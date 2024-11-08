import 'package:KinderConnect/Parent/home/registernewstudent.dart';
import 'package:KinderConnect/Parent/notification/reminder.dart';
import 'package:KinderConnect/Parent/profile/classactivities.dart';
import 'package:KinderConnect/welcome.dart';
import 'package:flutter/material.dart';
import 'attendance_form.dart';  // Import the AttendanceForm
import 'updatedetails.dart';

class HomePage extends StatefulWidget {
  final String parentId; // Add parentId field

  const HomePage({Key? key, required this.parentId}) : super(key: key); // Require parentId

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Track the selected index for the BottomNavigationBar

  // List of pages corresponding to each BottomNavigationBar item
  late List<Widget> _pages; 

  @override
  void initState() {
    super.initState();
    _pages = [
      ParentActivitiesPage(parentId: widget.parentId),  // Pass parentId to relevant pages
      HomeContent(parentId: widget.parentId),
      Reminder(parentId: widget.parentId),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color.fromARGB(255, 115, 143, 2),
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

class HomeContent extends StatefulWidget {
  final String parentId; // Accept parentId as a parameter

  const HomeContent({Key? key, required this.parentId}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 120.0, 20.0, 40.0),
            child: Column(
              children: [
                _buildSectionTitle('Child Management'),
                _buildTileRow([
                  _buildDashboardTile(
                    icon: Icons.notifications_active,
                    label: 'Notify Absence',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceForm(parentId: widget.parentId),
                      ),
                    ),
                  ),
                  _buildDashboardTile(
                    icon: Icons.edit_document,
                    label: 'Update Details',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChildDetailsForm(parentId: widget.parentId),
                      ),
                    ),
                  ),
                ]),
                
              ],
            ),
          ),

          Positioned(
            top: 60,  // Adjust the position to the top
            right: 10, // Align to the right side of the screen
            child: ElevatedButton(
              onPressed: () {
                // Navigate to Register New Student Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterNewStudent(parentId: widget.parentId), // Pass parentId to RegisterNewStudent
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey, // Button color
              ),
              child: const Text('Register New Child'),
            ),
          ),
          // Logout Icon at the top left corner
          Positioned(
            top: 60,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () {
                // Navigate to the welcome screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Welcome()),
                  (Route<dynamic> route) => false, // Remove all previous routes
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
  }) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}
