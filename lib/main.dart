import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/exam_screen.dart';
import 'screens/fees_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(CollegeERPApp());
}

class CollegeERPApp extends StatefulWidget {
  @override
  _CollegeERPAppState createState() => _CollegeERPAppState();
}

class _CollegeERPAppState extends State<CollegeERPApp> {
  int _selectedIndex = 0;

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    HomeScreen(),
    ExamScreen(),
    FeesScreen(),
    AttendanceScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College ERP System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Exam',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Fees',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}