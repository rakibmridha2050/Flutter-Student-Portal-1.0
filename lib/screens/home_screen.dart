import 'package:flutter/material.dart';
import 'package:schoolportal/main.dart';
import 'student_screen.dart';
import 'course_screen.dart';
import 'enrollment_screen.dart';
import 'grades_screen.dart';
import '../database/database_operations.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseOperations _dbOperations = DatabaseOperations();
  Map<String, int> _stats = {'students': 0, 'courses': 0, 'enrollments': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final stats = await _dbOperations.getDashboardStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('College ERP System'),
        backgroundColor: Colors.blue[200],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardStats,
            tooltip: 'Refresh Dashboard',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(221, 74, 3, 207),
              ),
            ),
            SizedBox(height: 20),

            // Stats Cards
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  _buildStatCard(
                    'Students',
                    _stats['students'] ?? 0,
                    Colors.blue,
                  ),
                  SizedBox(width: 10),
                  _buildStatCard(
                    'Courses',
                    _stats['courses'] ?? 0,
                    Colors.green,
                  ),
                  SizedBox(width: 10),
                  _buildStatCard(
                    'Enrollments',
                    _stats['enrollments'] ?? 0,
                    Colors.orange,
                  ),
                ],
              ),

            SizedBox(height: 30),
            Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Quick Actions
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildActionCard(
                    'Manage Students',
                    Icons.people,
                    Colors.blue,
                    () => _navigateTo(StudentScreen()),
                  ),
                  _buildActionCard(
                    'Manage Courses',
                    Icons.book,
                    Colors.green,
                    () => _navigateTo(CourseScreen()),
                  ),
                  _buildActionCard(
                    'Enroll Students',
                    Icons.add_circle,
                    Colors.orange,
                    () => _navigateTo(EnrollmentScreen()),
                  ),
                  _buildActionCard(
                    'View Grades (Student)',
                    Icons.grade,
                    Colors.purple,
                    () {
                      MockUser.setAsStudent();
                      _navigateTo(GradesScreen(courseId: 2,));
                    },
                  ),
                  _buildActionCard(
                    'Grade Students (Instructor)',
                    Icons.edit,
                    Colors.blue,
                    () {
                      MockUser.setAsInstructor();
                      _navigateTo(GradesScreen(courseId: 1,));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _loadDashboardStats,
      //   tooltip: 'Refresh Stats',
      //   child: Icon(Icons.refresh),
      // ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(_getStatIcon(title), color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getStatIcon(String title) {
    switch (title.toLowerCase()) {
      case 'students':
        return Icons.people;
      case 'courses':
        return Icons.book;
      case 'enrollments':
        return Icons.school;
      default:
        return Icons.info;
    }
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          onTap();
          // Refresh stats when returning from other screens
          await Future.delayed(Duration(milliseconds: 500));
          _loadDashboardStats();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                _getActionDescription(title),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getActionDescription(String title) {
    switch (title) {
      case 'Manage Students':
        return 'Add, edit, or remove students';
      case 'Manage Courses':
        return 'Create and manage courses';
      case 'Enroll Students':
        return 'Enroll students in courses';
      case 'View Grades':
        return 'View and manage grades';
      default:
        return '';
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) {
      // Refresh dashboard when returning
      _loadDashboardStats();
    });
  }
}
