import 'package:flutter/material.dart';
import 'package:schoolportal/database/database_helper.dart';

class CourseGradeDetailScreen extends StatefulWidget {
  final int courseId;
  final int studentId;

  const CourseGradeDetailScreen({
    Key? key,
    required this.courseId,
    required this.studentId,
  }) : super(key: key);

  @override
  _CourseGradeDetailScreenState createState() => _CourseGradeDetailScreenState();
}

class _CourseGradeDetailScreenState extends State<CourseGradeDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic> _gradeDetails = {};
  Map<String, dynamic>? _course;
  Map<String, dynamic>? _student;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load course details
    _course = await _dbHelper.getCourse(widget.courseId);
    
    // Load student details
    _student = await _dbHelper.getStudent(widget.studentId);
    
    // Load grade details
    _gradeDetails = await _dbHelper.getGradeSummary(
      widget.studentId,
      widget.courseId,
    );
    
    setState(() => _isLoading = false);
  }

  Widget _buildGradeCard() {
    if (_gradeDetails.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Grade Assigned Yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Your grade for this course is pending',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final grade = _gradeDetails['grade']?.toString() ?? '';
    final marks = _gradeDetails['marks']?.toString() ?? '0';
    
    return Card(
      color: _getGradeColor(grade).withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Grade Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildGradeCircle(grade),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marks Obtained',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '$marks / 100',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Grade Points',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      _getGradePoints(grade).toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            if (_gradeDetails['semester'] != null)
              Text(
                'Semester: ${_gradeDetails['semester']}',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
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

  // ADD THIS METHOD - Grade points calculator
  double _getGradePoints(String grade) {
    switch (grade) {
      case 'A': return 4.0;
      case 'B': return 3.0;
      case 'C': return 2.0;
      case 'D': return 1.0;
      case 'F': return 0.0;
      default: return 0.0;
    }
  }


  Widget _buildGradeCircle(String grade) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getGradeColor(grade),
      ),
      child: Center(
        child: Text(
          grade,
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadGradeReport,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Info
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.school, color: Colors.blue),
                      title: Text(
                        _course?['title'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Code: ${_course?['course_code']}'),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Student Info
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.green),
                      title: Text(
                        _student?['name'] ?? '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('ID: ${_student?['student_id']}'),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Grade Card
                  _buildGradeCard(),
                  
                  SizedBox(height: 20),
                  
                  // Performance Indicators
                  Text(
                    'Performance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildPerformanceIndicators(),
                ],
              ),
            ),
    );
  }

  Widget _buildPerformanceIndicators() {
    final grade = _gradeDetails['grade']?.toString() ?? '';
    
    List<Map<String, dynamic>> indicators = [
      {
        'label': 'Grade Status',
        'value': grade.isEmpty ? 'Pending' : 'Published',
        'icon': grade.isEmpty ? Icons.pending : Icons.check_circle,
        'color': grade.isEmpty ? Colors.orange : Colors.green,
      },
      {
        'label': 'Credit Points',
        'value': '${_course?['credits'] ?? 0}',
        'icon': Icons.star,
        'color': Colors.blue,
      },
      {
        'label': 'Result',
        'value': grade.isEmpty ? '---' : (grade == 'F' ? 'Fail' : 'Pass'),
        'icon': grade == 'F' ? Icons.warning : Icons.verified,
        'color': grade == 'F' ? Colors.red : Colors.green,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemCount: indicators.length,
      itemBuilder: (context, index) {
        final indicator = indicators[index];
        return Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  indicator['icon'] as IconData,
                  color: indicator['color'] as Color,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  indicator['value'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  indicator['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _downloadGradeReport() {
    // Implement PDF generation or export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download feature coming soon!')),
    );
  }
}