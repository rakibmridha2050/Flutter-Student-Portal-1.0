import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../database/database_operations.dart';
import '../database/database_helper.dart'; // Add this import

class EnrollmentScreen extends StatefulWidget {
  @override
  _EnrollmentScreenState createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final DatabaseOperations _dbOperations = DatabaseOperations();
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Create instance
  List<Student> _students = [];
  List<Course> _courses = [];
  List<Map<String, dynamic>> _enrollments = [];
  
  int? _selectedStudentId;
  int? _selectedCourseId;
  String _selectedSemester = 'Fall 2024';
  
  final List<String> _semesters = [
    'Fall 2024',
    'Spring 2024',
    'Summer 2024',
    'Fall 2023',
    'Spring 2023',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadStudents();
    await _loadCourses();
    await _loadEnrollments();
  }

  Future<void> _loadStudents() async {
    final students = await _dbOperations.getAllStudents();
    setState(() {
      _students = students;
    });
  }

  Future<void> _loadCourses() async {
    final courses = await _dbOperations.getAllCourses();
    setState(() {
      _courses = courses;
    });
  }

  Future<void> _loadEnrollments() async {
    final enrollments = await _dbOperations.getEnrollmentsWithDetails();
    setState(() {
      _enrollments = enrollments;
    });
  }

  Future<void> _enrollStudent() async {
    if (_selectedStudentId == null || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both student and course')),
      );
      return;
    }

    // Check if already enrolled
    final alreadyEnrolled = _enrollments.any((enrollment) =>
        enrollment['student_id'] == _selectedStudentId &&
        enrollment['course_id'] == _selectedCourseId);

    if (alreadyEnrolled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student is already enrolled in this course')),
      );
      return;
    }

    final enrollment = Enrollment(
      studentId: _selectedStudentId!,
      courseId: _selectedCourseId!,
      enrollmentDate: DateTime.now(),
    );

    await _dbOperations.enrollStudent(enrollment);
    await _loadEnrollments();
    
    // Clear selection
    setState(() {
      _selectedStudentId = null;
      _selectedCourseId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Student enrolled successfully')),
    );
  }

  Future<void> _updateEnrollmentStatus(int enrollmentId, String status) async {
    // FIXED: Use the instance
    final db = await _dbHelper.database;
    await db.update(
      'enrollments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [enrollmentId],
    );
    await _loadEnrollments();
  }

  // FIXED: Return Color instead of String
  Color _getStatusColor(String status) {
    switch (status) {
      case 'enrolled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'dropped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Enrollment'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Enrollment Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enroll Student in Course',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Student Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedStudentId,
                      decoration: InputDecoration(
                        labelText: 'Select Student',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _students.map((student) {
                        return DropdownMenuItem<int>(
                          value: student.id,
                          child: Text('${student.name} (${student.studentId})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStudentId = value;
                        });
                      },
                    ),
                    
                    SizedBox(height: 10),
                    
                    // Course Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedCourseId,
                      decoration: InputDecoration(
                        labelText: 'Select Course',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book),
                      ),
                      items: _courses.map((course) {
                        return DropdownMenuItem<int>(
                          value: course.id,
                          child: Text('${course.courseCode} - ${course.title}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCourseId = value;
                        });
                      },
                    ),
                    
                    SizedBox(height: 10),
                    
                    // Semester Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedSemester,
                      decoration: InputDecoration(
                        labelText: 'Semester',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: _semesters.map((semester) {
                        return DropdownMenuItem<String>(
                          value: semester,
                          child: Text(semester),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSemester = value!;
                        });
                      },
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Enroll Button
                    ElevatedButton(
                      onPressed: _enrollStudent,
                      child: Text('Enroll Student'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Enrollments List
            Expanded(
              child: _enrollments.isEmpty
                  ? Center(
                      child: Text(
                        'No enrollments found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _enrollments.length,
                      itemBuilder: (context, index) {
                        final enrollment = _enrollments[index];
                        final status = enrollment['status'] as String? ?? 'enrolled';
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getStatusColor(status),
                              child: Icon(
                                _getStatusIcon(status),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(enrollment['course_title']?.toString() ?? ''),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Student: ${enrollment['student_name']?.toString() ?? ''}'),
                                Text('Code: ${enrollment['course_code']?.toString() ?? ''}'),
                                Text('Enrolled: ${_formatDate(enrollment['enrollment_date']?.toString() ?? '')}'),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                _updateEnrollmentStatus(enrollment['id'] as int, value);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'enrolled',
                                  child: Text('Mark as Enrolled'),
                                ),
                                PopupMenuItem(
                                  value: 'completed',
                                  child: Text('Mark as Completed'),
                                ),
                                PopupMenuItem(
                                  value: 'dropped',
                                  child: Text('Mark as Dropped'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'enrolled':
        return Icons.check_circle;
      case 'completed':
        return Icons.school;
      case 'dropped':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}