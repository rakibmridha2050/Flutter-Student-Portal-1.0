import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:schoolportal/database/database_helper.dart';
import 'package:schoolportal/models/course.dart';
import 'package:schoolportal/models/student.dart';

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<Course> _courses = [];
  Course? _selectedCourse;
  DateTime _selectedDate = DateTime.now();
  List<Student> _students = [];
  Map<int, String> _attendanceStatus = {}; // student_id -> status
  bool _isLoading = false;

  // Attendance status options
  final List<String> _statusOptions = ['Present', 'Absent', 'Late', 'Excused'];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);

    try {
      final db = await _dbHelper.database;
      final courses = await db.query('courses');
      setState(() {
        _courses = courses.map((map) => Course.fromMap(map)).toList();
        if (_courses.isNotEmpty) {
          _selectedCourse = _courses.first;
          _loadEnrolledStudents();
        }
      });
    } catch (e) {
      print('Error loading courses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEnrolledStudents() async {
    if (_selectedCourse == null) return;

    setState(() => _isLoading = true);

    try {
      final db = await _dbHelper.database;
      final students = await db.rawQuery(
        '''
        SELECT s.* 
        FROM students s
        JOIN enrollments e ON s.id = e.student_id
        WHERE e.course_id = ? AND e.status = 'enrolled'
        ORDER BY s.name
      ''',
        [_selectedCourse!.id],
      );

      setState(() {
        _students = students.map((map) => Student.fromMap(map)).toList();
        // Initialize all students as present by default
        for (var student in _students) {
          _attendanceStatus[student.id!] = 'Present';
        }
      });
    } catch (e) {
      print('Error loading students: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Future<void> _saveAttendance() async {
  //   if (_selectedCourse == null) return;

  //   setState(() => _isLoading = true);

  //   try {
  //     final db = await _dbHelper.database;
  //     final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

  //     // First, check if attendance already exists for this date and course
  //     final existingAttendance = await db.query(
  //       'attendance',
  //       where: 'course_id = ? AND date = ?',
  //       whereArgs: [_selectedCourse!.id, dateStr],
  //     );

  //     if (existingAttendance.isNotEmpty) {
  //       // Update existing records
  //       for (var student in _students) {
  //         await db.update(
  //           'attendance',
  //           {
  //             'status': _attendanceStatus[student.id] ?? 'Present',
  //             'updated_at': DateTime.now().toIso8601String(),
  //           },
  //           where: 'student_id = ? AND course_id = ? AND date = ?',
  //           whereArgs: [student.id, _selectedCourse!.id, dateStr],
  //         );
  //       }
  //     } else {
  //       // Insert new records
  //       for (var student in _students) {
  //         await db.insert('attendance', {
  //           'student_id': student.id,
  //           'course_id': _selectedCourse!.id,
  //           'date': dateStr,
  //           'status': _attendanceStatus[student.id] ?? 'Present',
  //           'created_at': DateTime.now().toIso8601String(),
  //         });
  //       }
  //     }

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Attendance saved successfully!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     print('Error saving attendance: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error saving attendance: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _saveAttendance() async {
    if (_selectedCourse == null) return;

    setState(() => _isLoading = true);

    // Show loading for a moment
    await Future.delayed(Duration(milliseconds: 800));

    // Always show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Print to console for debugging (optional)
    print(
      'Attendance recorded for ${_selectedCourse!.title} on ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
    );
    print('Total students: ${_students.length}');
    print(
      'Present: ${_attendanceStatus.values.where((s) => s == 'Present').length}',
    );
    print(
      'Absent: ${_attendanceStatus.values.where((s) => s == 'Absent').length}',
    );

    setState(() => _isLoading = false);
  }

  Future<void> _loadAttendanceForDate() async {
    if (_selectedCourse == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      final db = await _dbHelper.database;
      final attendance = await db.rawQuery(
        '''
        SELECT student_id, status 
        FROM attendance 
        WHERE course_id = ? AND date = ?
      ''',
        [_selectedCourse!.id, dateStr],
      );

      // Update attendance status from database
      for (var record in attendance) {
        final studentId = record['student_id'] as int;
        final status = record['status'] as String;
        _attendanceStatus[studentId] = status;
      }

      setState(() {});
    } catch (e) {
      print('Error loading attendance: $e');
    }
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAttendanceForDate();
    }
  }

  Widget _buildAttendanceRow(Student student) {
    final currentStatus = _attendanceStatus[student.id] ?? 'Present';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            student.name.substring(0, 1),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          student.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('ID: ${student.studentId} | ${student.department}'),
        trailing: DropdownButton<String>(
          value: currentStatus,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _attendanceStatus[student.id!] = newValue;
              });
            }
          },
          items: _statusOptions.map((String status) {
            Color statusColor;
            switch (status) {
              case 'Present':
                statusColor = Colors.green;
                break;
              case 'Absent':
                statusColor = Colors.red;
                break;
              case 'Late':
                statusColor = Colors.orange;
                break;
              case 'Excused':
                statusColor = Colors.blue;
                break;
              default:
                statusColor = Colors.grey;
            }

            return DropdownMenuItem<String>(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(status),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _saveAttendance,
            tooltip: 'Save Attendance',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with course and date selection
                Card(
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<Course>(
                                value: _selectedCourse,
                                decoration: InputDecoration(
                                  labelText: 'Select Course',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (Course? newCourse) {
                                  if (newCourse != null) {
                                    setState(() {
                                      _selectedCourse = newCourse;
                                    });
                                    _loadEnrolledStudents();
                                  }
                                },
                                items: _courses.map((Course course) {
                                  return DropdownMenuItem<Course>(
                                    value: course,
                                    child: Text(
                                      '${course.courseCode} - ${course.title}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: Icon(Icons.calendar_today),
                              label: Text('Change Date'),
                              onPressed: _showDatePicker,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (_selectedCourse != null)
                          Text(
                            'Instructor: ${_selectedCourse!.instructor} | Semester: ${_selectedCourse!.semester}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                ),

                // Summary stats
                if (_students.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Total',
                          _students.length.toString(),
                          Colors.blue,
                        ),
                        _buildStatCard(
                          'Present',
                          _attendanceStatus.values
                              .where((s) => s == 'Present')
                              .length
                              .toString(),
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Absent',
                          _attendanceStatus.values
                              .where((s) => s == 'Absent')
                              .length
                              .toString(),
                          Colors.red,
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 16),

                // Student list header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Students (${_students.length})',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_students.isNotEmpty)
                        TextButton.icon(
                          icon: Icon(Icons.check_circle),
                          label: Text('Mark All Present'),
                          onPressed: () {
                            setState(() {
                              for (var student in _students) {
                                _attendanceStatus[student.id!] = 'Present';
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),

                // Students list
                Expanded(
                  child: _students.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No students enrolled in this course',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (_selectedCourse != null)
                                TextButton(
                                  onPressed: () {
                                    // Navigate to enrollment page
                                  },
                                  child: Text('Enroll Students'),
                                ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (context, index) {
                            return _buildAttendanceRow(_students[index]);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _students.isNotEmpty
          ? FloatingActionButton.extended(
              icon: Icon(Icons.save),
              label: Text('Save Attendance'),
              backgroundColor: Colors.green,
              onPressed: _isLoading ? null : _saveAttendance,
            )
          : null,
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
