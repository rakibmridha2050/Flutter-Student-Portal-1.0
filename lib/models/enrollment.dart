class Enrollment {
  int? id;
  int studentId;
  int courseId;
  DateTime enrollmentDate;
  String status; // 'enrolled', 'completed', 'dropped'

  Enrollment({
    this.id,
    required this.studentId,
    required this.courseId,
    required this.enrollmentDate,
    this.status = 'enrolled',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'course_id': courseId,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'status': status,
    };
  }

  factory Enrollment.fromMap(Map<String, dynamic> map) {
    return Enrollment(
      id: map['id'],
      studentId: map['student_id'],
      courseId: map['course_id'],
      enrollmentDate: DateTime.parse(map['enrollment_date']),
      status: map['status'],
    );
  }
}