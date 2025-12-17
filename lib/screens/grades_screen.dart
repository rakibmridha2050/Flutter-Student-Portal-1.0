import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/grade.dart';
import '../database/database_operations.dart';
import '../database/database_helper.dart';

class GradesScreen extends StatefulWidget {
  @override
  _GradesScreenState createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final DatabaseOperations _dbOperations = DatabaseOperations();
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Create instance
  List<Student> _students = [];
  List<Course> _courses = [];
  List<Map<String, dynamic>> _grades = [];
  List<Map<String, dynamic>> _enrollments = [];
  
  int? _selectedStudentId;
  int? _selectedCourseId;
  int? _selectedEnrollmentId;
  String _selectedSemester = 'Fall 2024';
  double _marks = 0.0;
  String _grade = 'A';
  
  final List<String> _gradeLetters = ['A', 'B', 'C', 'D', 'F'];
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
    final db = await _dbHelper.database;
    final enrollments = await db.rawQuery('''
      SELECT e.id, s.name as student_name, c.title as course_title
      FROM enrollments e
      JOIN students s ON e.student_id = s.id
      JOIN courses c ON e.course_id = c.id
      WHERE e.status = 'enrolled'
    ''');
    setState(() {
      _enrollments = enrollments;
    });
  }

  Future<void> _loadStudentGrades(int studentId) async {
    final grades = await _dbOperations.getStudentGrades(studentId);
    setState(() {
      _grades = grades;
    });
  }

  Future<void> _addGrade() async {
    if (_selectedStudentId == null || _selectedCourseId == null || _selectedEnrollmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select student and course')),
      );
      return;
    }

    final grade = Grade(
      enrollmentId: _selectedEnrollmentId!,
      studentId: _selectedStudentId!,
      courseId: _selectedCourseId!,
      marks: _marks,
      grade: _grade,
      semester: _selectedSemester,
    );

    await _dbOperations.addGrade(grade);
    
    // Update enrollment status to completed
    final db = await _dbHelper.database;
    await db.update(
      'enrollments',
      {'status': 'completed'},
      where: 'id = ?',
      whereArgs: [_selectedEnrollmentId],
    );
    
    await _loadEnrollments();
    
    if (_selectedStudentId != null) {
      await _loadStudentGrades(_selectedStudentId!);
    }
    
    // Clear form
    setState(() {
      _marks = 0.0;
      _grade = 'A';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Grade added successfully')),
    );
  }

  void _onStudentChanged(int? studentId) {
    setState(() {
      _selectedStudentId = studentId;
      if (studentId != null) {
        _loadStudentGrades(studentId);
      } else {
        _grades.clear();
      }
    });
  }

  double _calculateGPA() {
    if (_grades.isEmpty) return 0.0;
    
    double totalPoints = 0.0;
    int totalCredits = 0;
    
    for (var grade in _grades) {
      final credits = grade['credits'] as int? ?? 0;
      final gradeLetter = grade['grade'] as String? ?? 'F';
      
      double points = _gradeToPoints(gradeLetter);
      totalPoints += points * credits;
      totalCredits += credits;
    }
    
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  double _gradeToPoints(String grade) {
    switch (grade) {
      case 'A': return 4.0;
      case 'B': return 3.0;
      case 'C': return 2.0;
      case 'D': return 1.0;
      case 'F': return 0.0;
      default: return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Management'),
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
            // GPA Summary
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall GPA',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _calculateGPA().toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Courses',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          _grades.length.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Student Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Student to View Grades',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: _selectedStudentId,
                      decoration: InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _students.map((student) {
                        return DropdownMenuItem<int>(
                          value: student.id,
                          child: Text('${student.name} (${student.studentId})'),
                        );
                      }).toList(),
                      onChanged: _onStudentChanged,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Add Grade Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Grade',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Enrollment Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedEnrollmentId,
                      decoration: InputDecoration(
                        labelText: 'Select Enrollment',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.list),
                      ),
                      items: _enrollments.map((enrollment) {
                        return DropdownMenuItem<int>(
                          value: enrollment['id'] as int,
                          child: Text(
                            '${enrollment['student_name']} - ${enrollment['course_title']}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedEnrollmentId = value;
                        });
                      },
                    ),
                    
                    SizedBox(height: 10),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _marks.toString(),
                            decoration: InputDecoration(
                              labelText: 'Marks',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.score),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            onChanged: (value) {
                              final parsedValue = double.tryParse(value) ?? 0.0;
                              setState(() {
                                _marks = parsedValue;
                                // Auto-calculate grade based on marks
                                if (_marks >= 90) _grade = 'A';
                                else if (_marks >= 80) _grade = 'B';
                                else if (_marks >= 70) _grade = 'C';
                                else if (_marks >= 60) _grade = 'D';
                                else _grade = 'F';
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _grade,
                            decoration: InputDecoration(
                              labelText: 'Grade',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.grade),
                            ),
                            items: _gradeLetters.map((letter) {
                              return DropdownMenuItem<String>(
                                value: letter,
                                child: Text('Grade $letter'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _grade = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 10),
                    
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
                    
                    ElevatedButton(
                      onPressed: _addGrade,
                      child: Text('Add Grade'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Grades List
            if (_selectedStudentId != null)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grade History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _grades.isEmpty
                        ? Expanded(
                            child: Center(
                              child: Text(
                                'No grades recorded for this student',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _grades.length,
                              itemBuilder: (context, index) {
                                final grade = _grades[index];
                                final gradeLetter = grade['grade'] as String? ?? 'F';
                                final marks = grade['marks'] as double? ?? 0.0;
                                final credits = grade['credits'] as int? ?? 0;
                                
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getGradeColor(gradeLetter),
                                      child: Text(
                                        gradeLetter,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(grade['course_title']?.toString() ?? ''),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Code: ${grade['course_code']?.toString() ?? ''}'),
                                        Text('Semester: ${grade['semester']?.toString() ?? ''}'),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          marks.toStringAsFixed(1),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '$credits credits',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
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
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.orangeAccent;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}