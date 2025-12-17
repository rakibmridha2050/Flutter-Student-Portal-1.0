class Student {
  int? id;
  String studentId;
  String name;
  String email;
  String phone;
  String department;
  DateTime enrollmentDate;
  String? address;

  Student({
    this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.enrollmentDate,
    this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'enrollment_date': enrollmentDate.toIso8601String(),
      'address': address,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      studentId: map['student_id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      department: map['department'],
      enrollmentDate: DateTime.parse(map['enrollment_date']),
      address: map['address'],
    );
  }
}