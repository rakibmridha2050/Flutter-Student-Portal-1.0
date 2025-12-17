class Grade {
  int? id;
  int enrollmentId;
  int studentId;
  int courseId;
  double marks;
  String grade;
  String semester;

  Grade({
    this.id,
    required this.enrollmentId,
    required this.studentId,
    required this.courseId,
    required this.marks,
    required this.grade,
    required this.semester,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'enrollment_id': enrollmentId,
      'student_id': studentId,
      'course_id': courseId,
      'marks': marks,
      'grade': grade,
      'semester': semester,
    };
  }

  factory Grade.fromMap(Map<String, dynamic> map) {
    return Grade(
      id: map['id'],
      enrollmentId: map['enrollment_id'],
      studentId: map['student_id'],
      courseId: map['course_id'],
      marks: map['marks'],
      grade: map['grade'],
      semester: map['semester'],
    );
  }
}