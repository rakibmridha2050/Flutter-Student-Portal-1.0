import 'package:flutter/material.dart';
import '../models/course.dart';
import '../database/database_operations.dart';

class CourseScreen extends StatefulWidget {
  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final DatabaseOperations _dbOperations = DatabaseOperations();
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _searchController.addListener(_filterCourses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final courses = await _dbOperations.getAllCourses();
      setState(() {
        _courses = courses;
        _filteredCourses = courses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterCourses() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredCourses = _courses;
      });
    } else {
      setState(() {
        _filteredCourses = _courses.where((course) {
          return course.title.toLowerCase().contains(query) ||
              course.courseCode.toLowerCase().contains(query) ||
              course.department.toLowerCase().contains(query) ||
              course.instructor.toLowerCase().contains(query) ||
              course.semester.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Future<void> _deleteCourse(int id) async {
    final shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Course'),
        content: Text(
          'Are you sure you want to delete this course? This will also delete related enrollments and grades.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _dbOperations.deleteCourse(id);
        await _loadCourses();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course deleted successfully'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting course: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showAddCourseForm({Course? course}) {
    final isEditing = course != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCourseForm(
        course: course,
        onCourseAdded: _loadCourses,
        isEditing: isEditing,
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCourseColor(course.department).withOpacity(0.1),
              _getCourseColor(course.department).withOpacity(0.05),
            ],
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.all(8),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getCourseColor(course.department),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.book, color: Colors.white, size: 28),
          ),
          title: Text(
            course.title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.code, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(course.courseCode, style: TextStyle(fontSize: 13)),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(course.instructor, style: TextStyle(fontSize: 13)),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.school, size: 14, color: Colors.grey),
                  SizedBox(width: 5),
                  Text(course.department, style: TextStyle(fontSize: 13)),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Chip(
                    label: Text(
                      '${course.credits} Credits',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  Chip(
                    label: Text(
                      'Max ${course.maxStudents}',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  Chip(
                    label: Text(
                      course.semester,
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: Colors.purple,
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showAddCourseForm(course: course);
              } else if (value == 'delete') {
                _deleteCourse(course.id!);
              }
            },
            icon: Icon(Icons.more_vert, color: Colors.grey),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCourseColor(String department) {
    final colors = {
      'Computer Science': Colors.blue,
      'Electrical Engineering': Colors.green,
      'Mechanical Engineering': Colors.orange,
      'Civil Engineering': Colors.red,
      'Business Administration': Colors.purple,
      'Medicine': Colors.teal,
      'Law': Colors.indigo,
      'Arts': Colors.pink,
      'Science': Colors.cyan,
      'Mathematics': Colors.amber,
    };

    return colors[department] ?? Colors.blue;
  }

  Widget _buildCourseList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No courses found'
                  : 'No courses available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add your first course',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredCourses.length,
      itemBuilder: (context, index) =>
          _buildCourseCard(_filteredCourses[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Management'),
        backgroundColor: const Color.fromARGB(255, 103, 154, 173),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCourses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: const Color.fromARGB(255, 165, 167, 165),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses by name...',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => _filterCourses(),
            ),
          ),

          // Course Count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Courses: ${_courses.length}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Text(
                    'Found: ${_filteredCourses.length}',
                    style: TextStyle(color: Colors.green[700]),
                  ),
              ],
            ),
          ),

          // Courses List
          Expanded(child: _buildCourseList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCourseForm(),
        icon: Icon(Icons.add),
        label: Text('Add Course'),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
    );
  }
}

class AddCourseForm extends StatefulWidget {
  final Course? course;
  final VoidCallback onCourseAdded;
  final bool isEditing;

  const AddCourseForm({
    this.course,
    required this.onCourseAdded,
    required this.isEditing,
  });

  @override
  _AddCourseFormState createState() => _AddCourseFormState();
}

class _AddCourseFormState extends State<AddCourseForm> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _instructorController = TextEditingController();

  // Simple text controllers instead of dropdowns
  final _departmentController = TextEditingController();
  final _creditsController = TextEditingController();
  final _maxStudentsController = TextEditingController();
  final _semesterController = TextEditingController();

  final DatabaseOperations _dbOperations = DatabaseOperations();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.course != null) {
      final course = widget.course!;
      _codeController.text = course.courseCode;
      _titleController.text = course.title;
      _departmentController.text = course.department;
      _instructorController.text = course.instructor;
      _creditsController.text = course.credits.toString();
      _maxStudentsController.text = course.maxStudents.toString();
      _semesterController.text = course.semester;
    } else {
      // Set default values
      _creditsController.text = '3';
      _maxStudentsController.text = '50';
      _semesterController.text = 'Fall 2024';
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _departmentController.dispose();
    _instructorController.dispose();
    _creditsController.dispose();
    _maxStudentsController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final course = Course(
          id: widget.course?.id,
          courseCode: _codeController.text.trim(),
          title: _titleController.text.trim(),
          department: _departmentController.text.trim(),
          credits: int.tryParse(_creditsController.text.trim()) ?? 3,
          instructor: _instructorController.text.trim(),
          maxStudents: int.tryParse(_maxStudentsController.text.trim()) ?? 50,
          semester: _semesterController.text.trim(),
        );

        if (widget.isEditing) {
          await _dbOperations.updateCourse(course);
        } else {
          await _dbOperations.insertCourse(course);
        }

        widget.onCourseAdded();
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Course updated successfully'
                  : 'Course added successfully',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error saving course: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEditing ? 'Edit Course' : 'Add New Course',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Course Code
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Course Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.code),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Course Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter course title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Department - Simple text field instead of dropdown
              TextFormField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                  hintText: 'e.g., Computer Science',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter department';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Instructor
              TextFormField(
                controller: _instructorController,
                decoration: InputDecoration(
                  labelText: 'Instructor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructor name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),

              Row(
                children: [
                  // Credits
                  Expanded(
                    child: TextFormField(
                      controller: _creditsController,
                      decoration: InputDecoration(
                        labelText: 'Credits',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.star),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter credits';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 15),

                  // Max Students
                  Expanded(
                    child: TextFormField(
                      controller: _maxStudentsController,
                      decoration: InputDecoration(
                        labelText: 'Max Students',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter max students';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              // Semester - Simple text field instead of dropdown
              TextFormField(
                controller: _semesterController,
                decoration: InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'e.g., Fall 2024',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter semester';
                  }
                  return null;
                },
              ),
              SizedBox(height: 25),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.isEditing ? 'Update Course' : 'Add Course',
                        style: TextStyle(fontSize: 16),
                      ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                  backgroundColor: widget.isEditing
                      ? Colors.orange
                      : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
