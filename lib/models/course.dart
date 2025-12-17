class Course {
  int? id;
  String courseCode;
  String title;
  String department;
  int credits;
  String instructor;
  int maxStudents;
  String semester;

  Course({
    this.id,
    required this.courseCode,
    required this.title,
    required this.department,
    required this.credits,
    required this.instructor,
    required this.maxStudents,
    required this.semester,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_code': courseCode,
      'title': title,
      'department': department,
      'credits': credits,
      'instructor': instructor,
      'max_students': maxStudents,
      'semester': semester,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      courseCode: map['course_code'],
      title: map['title'],
      department: map['department'],
      credits: map['credits'],
      instructor: map['instructor'],
      maxStudents: map['max_students'],
      semester: map['semester'],
    );
  }
}