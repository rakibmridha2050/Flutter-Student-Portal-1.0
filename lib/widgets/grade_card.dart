import 'package:flutter/material.dart';

class GradeCard extends StatelessWidget {
  final Map<String, dynamic> grade;
  final VoidCallback? onDelete;
  
  const GradeCard({
    Key? key,
    required this.grade,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gradeLetter = grade['grade'] as String? ?? 'F';
    final marks = grade['marks'] as double? ?? 0.0;
    final credits = grade['credits'] as int? ?? 0;
    final points = _gradeToPoints(gradeLetter);
    
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
        title: Text(
          grade['course_title']?.toString() ?? 'Unknown Course',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Code: ${grade['course_code']?.toString() ?? ''}'),
            Text('Semester: ${grade['semester']?.toString() ?? ''}'),
            Text('Credits: $credits | Points: ${points.toStringAsFixed(1)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              marks.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '/100',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: Icon(Icons.delete, size: 18),
                color: Colors.red[300],
                onPressed: onDelete,
              ),
          ],
        ),
        onTap: () {
          // Show grade details
          _showGradeDetails(context);
        },
      ),
    );
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

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return Colors.green;
      case 'B': return Colors.blue;
      case 'C': return Colors.orange;
      case 'D': return Colors.orangeAccent;
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showGradeDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Grade Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Course', grade['course_title']?.toString() ?? ''),
            _buildDetailRow('Code', grade['course_code']?.toString() ?? ''),
            _buildDetailRow('Marks', '${grade['marks']?.toStringAsFixed(1) ?? ''}/100'),
            _buildDetailRow('Grade', grade['grade']?.toString() ?? ''),
            _buildDetailRow('Semester', grade['semester']?.toString() ?? ''),
            _buildDetailRow('Credits', grade['credits']?.toString() ?? '0'),
            _buildDetailRow('Date Added', grade['created_at']?.toString() ?? ''),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}