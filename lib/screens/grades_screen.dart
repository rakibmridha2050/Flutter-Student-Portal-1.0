import 'package:flutter/material.dart';
import 'package:schoolportal/database/database_helper.dart';
import 'package:schoolportal/screens/detail_grade_screen.dart';
import 'package:sqflite/sqflite.dart';

// Assuming you have a way to get current user info
class CurrentUser {
  static String? name;
  static String? role; // 'student' or 'instructor'
  static int? id;
}

class GradesScreen extends StatefulWidget {
  const GradesScreen({Key? key, required courseId}) : super(key: key);

  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserCourses();
  }

  Future<void> _loadUserCourses() async {
    setState(() => _isLoading = true);
    
    if (CurrentUser.role == 'instructor' && CurrentUser.name != null) {
      // Load courses taught by instructor
      _courses = await _dbHelper.getCoursesByInstructor(CurrentUser.name!);
    } else if (CurrentUser.role == 'student' && CurrentUser.id != null) {
      // Load courses taken by student
      _courses = await _dbHelper.getStudentCourses(CurrentUser.id!);
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grades Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUserCourses,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              CurrentUser.role == 'instructor'
                  ? 'No courses assigned to you'
                  : 'No courses enrolled',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return _buildCourseCard(course);
      },
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    final hasGrade = course['grade'] != null;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasGrade ? Colors.green : Colors.blue,
          child: Icon(
            hasGrade ? Icons.grade : Icons.school,
            color: Colors.white,
          ),
        ),
        title: Text(
          course['title']?.toString() ?? '',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${course['course_code']}'),
            Text('Semester: ${course['semester']}'),
            if (hasGrade) ...[
              SizedBox(height: 4),
              Row(
                children: [
                  Chip(
                    label: Text(
                      'Grade: ${course['grade']}',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getGradeColor(course['grade']?.toString() ?? ''),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Marks: ${course['marks'] ?? 0}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: CurrentUser.role == 'instructor'
            ? Icon(Icons.edit, color: Colors.blue)
            : Icon(Icons.visibility, color: Colors.green),
        onTap: () {
          if (CurrentUser.role == 'instructor') {
            // Navigate to grading screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GradesScreen(courseId: course['id']),
              ),
            );
          } else {
            // Navigate to student's detailed grade view
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseGradeDetailScreen(
                  courseId: course['id'],
                  studentId: CurrentUser.id!,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return Colors.green;
      case 'B': return Colors.lightGreen;
      case 'C': return Colors.amber;
      case 'D': return Colors.orange;
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }
}