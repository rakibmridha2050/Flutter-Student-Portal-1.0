import 'package:flutter/material.dart';
import '../models/student.dart';
import '../database/database_operations.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final DatabaseOperations _dbOperations = DatabaseOperations();
  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _addressController = TextEditingController();
  final _searchController = TextEditingController();
  
  bool _showAddForm = false;
  bool _isLoading = false;
  
  // Departments list
  final List<String> _departments = [
    'Computer Science',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Civil Engineering',
    'Business Administration',
    'Medicine',
    'Law',
    'Arts',
    'Science',
    'Mathematics'
  ];

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final students = await _dbOperations.getAllStudents();
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading students: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredStudents = _students;
      });
    } else {
      setState(() {
        _filteredStudents = _students.where((student) {
          return student.name.toLowerCase().contains(query) ||
                 student.studentId.toLowerCase().contains(query) ||
                 student.department.toLowerCase().contains(query) ||
                 student.email.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Future<void> _addStudent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final student = Student(
          studentId: _studentIdController.text.trim(),
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          department: _departmentController.text.trim(),
          enrollmentDate: DateTime.now(),
          address: _addressController.text.trim(),
        );

        await _dbOperations.insertStudent(student);
        await _loadStudents();
        _clearForm();
        _toggleAddForm();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student added successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding student: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _studentIdController.clear();
    _emailController.clear();
    _phoneController.clear();
    _departmentController.clear();
    _addressController.clear();
  }

  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;
      if (!_showAddForm) {
        _clearForm();
        _formKey.currentState?.reset();
      }
    });
  }

  Future<void> _deleteStudent(int id) async {
    final shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Student'),
        content: Text('Are you sure you want to delete this student?'),
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
        await _dbOperations.deleteStudent(id);
        await _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting student: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _editStudent(Student student) async {
    _nameController.text = student.name;
    _studentIdController.text = student.studentId;
    _emailController.text = student.email;
    _phoneController.text = student.phone;
    _departmentController.text = student.department;
    _addressController.text = student.address ?? '';
    
    setState(() {
      _showAddForm = true;
    });
    
    // Wait for form to show then update
    await Future.delayed(Duration(milliseconds: 100));
    
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _buildAddStudentForm(isEditing: true, student: student),
      ),
    );
    
    if (result == true) {
      await _loadStudents();
    }
  }

  Widget _buildAddStudentForm({bool isEditing = false, Student? student}) {
    return Container(
      padding: EdgeInsets.all(20),
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
                  isEditing ? 'Edit Student' : 'Add New Student',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                    _clearForm();
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _studentIdController,
              decoration: InputDecoration(
                labelText: 'Student ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              readOnly: isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter student ID';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter name';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _departmentController.text.isNotEmpty 
                  ? _departmentController.text 
                  : null,
              decoration: InputDecoration(
                labelText: 'Department',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
              items: _departments.map((dept) {
                return DropdownMenuItem<String>(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _departmentController.text = value ?? '';
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select department';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 2,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    if (isEditing && student != null) {
                      // Update existing student
                      final updatedStudent = Student(
                        id: student.id,
                        studentId: _studentIdController.text.trim(),
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phone: _phoneController.text.trim(),
                        department: _departmentController.text.trim(),
                        enrollmentDate: student.enrollmentDate,
                        address: _addressController.text.trim(),
                      );
                      await _dbOperations.updateStudent(updatedStudent);
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Student updated successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      // Add new student
                      await _addStudent();
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Update Student' : 'Add Student'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: isEditing ? Colors.orange : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No students found for "${_searchController.text}"'
                  : 'No students found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            if (!_searchController.text.isNotEmpty)
              TextButton(
                onPressed: _toggleAddForm,
                child: Text('Add First Student'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getDepartmentColor(student.department),
              child: Text(
                student.name[0].toUpperCase(),
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              student.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${student.studentId}'),
                Text('Dept: ${student.department}'),
                Text('Email: ${student.email}'),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editStudent(student);
                } else if (value == 'delete') {
                  _deleteStudent(student.id!);
                }
              },
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
            onTap: () {
              // Show student details
              _showStudentDetails(student);
            },
          ),
        );
      },
    );
  }

  void _showStudentDetails(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getDepartmentColor(student.department),
                  radius: 30,
                  child: Text(
                    student.name[0].toUpperCase(),
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        student.studentId,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDetailRow(Icons.email, 'Email', student.email),
            _buildDetailRow(Icons.phone, 'Phone', student.phone),
            _buildDetailRow(Icons.school, 'Department', student.department),
            _buildDetailRow(Icons.calendar_today, 'Enrollment Date', 
                '${student.enrollmentDate.day}/${student.enrollmentDate.month}/${student.enrollmentDate.year}'),
            if (student.address != null && student.address!.isNotEmpty)
              _buildDetailRow(Icons.home, 'Address', student.address!),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _editStudent(student);
                    },
                    child: Text('Edit'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Close'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    
    int index = department.hashCode % colors.length;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Management'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStudents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(10),
            color: Colors.grey[50],
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, ID, department or email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (value) => _filterStudents(),
            ),
          ),
          
          // Student Count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Students: ${_students.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Text(
                    'Found: ${_filteredStudents.length}',
                    style: TextStyle(
                      color: Colors.green[700],
                    ),
                  ),
              ],
            ),
          ),
          
          // Students List
          Expanded(
            child: _buildStudentList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _clearForm();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: _buildAddStudentForm(),
            ),
          );
        },
        icon: Icon(Icons.person_add),
        label: Text('Add Student'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}