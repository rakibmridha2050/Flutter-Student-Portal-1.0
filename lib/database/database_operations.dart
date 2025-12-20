import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/enrollment.dart';
import '../models/grade.dart';

class DatabaseOperations {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Helper method for safe type conversion
  T _safeCast<T>(dynamic value, T defaultValue) {
    if (value is T) {
      return value;
    }
    return defaultValue;
  }

  // Get database instance
  Future<Database> get database async {
    return await _dbHelper.database;
  }

  // ================================
  // STUDENT OPERATIONS
  // ================================
  
  Future<int> insertStudent(Student student) async {
    final db = await _dbHelper.database;
    return await db.insert('students', student.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Student>> getAllStudents() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<Student?> getStudentById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Student.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateStudent(Student student) async {
    final db = await _dbHelper.database;
    return await db.update('students', student.toMap(),
        where: 'id = ?',
        whereArgs: [student.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteStudent(int id) async {
    final db = await _dbHelper.database;
    // Delete related records first
    await db.delete('enrollments', where: 'student_id = ?', whereArgs: [id]);
    await db.delete('grades', where: 'student_id = ?', whereArgs: [id]);
    // Then delete student
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // ================================
  // COURSE OPERATIONS
  // ================================
  
  Future<int> insertCourse(Course course) async {
    final db = await _dbHelper.database;
    return await db.insert('courses', course.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Course>> getAllCourses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) => Course.fromMap(maps[i]));
  }

  Future<Course?> getCourseById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Course.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateCourse(Course course) async {
    final db = await _dbHelper.database;
    return await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteCourse(int id) async {
    final db = await _dbHelper.database;
    // Delete related records first
    await db.delete('enrollments', where: 'course_id = ?', whereArgs: [id]);
    await db.delete('grades', where: 'course_id = ?', whereArgs: [id]);
    // Then delete course
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // ================================
  // ENROLLMENT OPERATIONS
  // ================================
  
  Future<int> enrollStudent(Enrollment enrollment) async {
    final db = await _dbHelper.database;
    return await db.insert('enrollments', enrollment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getEnrollmentsWithDetails() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        e.id,
        e.student_id,
        e.course_id,
        s.name as student_name,
        s.student_id as student_code,
        c.title as course_title,
        c.course_code,
        e.enrollment_date,
        e.status
      FROM enrollments e
      JOIN students s ON e.student_id = s.id
      JOIN courses c ON e.course_id = c.id
      ORDER BY e.enrollment_date DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getStudentEnrollments(int studentId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT e.*, c.title, c.course_code, c.credits
      FROM enrollments e
      JOIN courses c ON e.course_id = c.id
      WHERE e.student_id = ?
      ORDER BY e.enrollment_date DESC
    ''', [studentId]);
  }

  Future<List<Map<String, dynamic>>> getCourseEnrollments(int courseId) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT e.*, s.name, s.student_id
      FROM enrollments e
      JOIN students s ON e.student_id = s.id
      WHERE e.course_id = ?
      ORDER BY e.enrollment_date DESC
    ''', [courseId]);
  }

  Future<int> updateEnrollmentStatus(int enrollmentId, String status) async {
    final db = await _dbHelper.database;
    return await db.update(
      'enrollments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [enrollmentId],
    );
  }

  Future<int> deleteEnrollment(int id) async {
    final db = await _dbHelper.database;
    // Delete related grade if exists
    await db.delete('grades', where: 'enrollment_id = ?', whereArgs: [id]);
    // Then delete enrollment
    return await db.delete('enrollments', where: 'id = ?', whereArgs: [id]);
  }

  // ================================
  // GRADE OPERATIONS
  // ================================
  
  Future<int> addGrade(Grade grade) async {
    final db = await _dbHelper.database;
    return await db.insert('grades', grade.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getStudentGrades(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        g.id,
        g.enrollment_id,
        g.marks,
        g.grade,
        g.semester,
        g.created_at,
        c.title as course_title,
        c.course_code,
        c.credits
      FROM grades g
      JOIN courses c ON g.course_id = c.id
      WHERE g.student_id = ?
      ORDER BY g.semester DESC, g.created_at DESC
    ''', [studentId]);
    
    return maps.map((map) {
      return {
        'id': _safeCast<int>(map['id'], 0),
        'enrollment_id': _safeCast<int>(map['enrollment_id'], 0),
        'marks': _safeCast<double>(map['marks'], 0.0),
        'grade': _safeCast<String>(map['grade'], ''),
        'semester': _safeCast<String>(map['semester'], ''),
        'created_at': _safeCast<String>(map['created_at'], ''),
        'course_title': _safeCast<String>(map['course_title'], ''),
        'course_code': _safeCast<String>(map['course_code'], ''),
        'credits': _safeCast<int>(map['credits'], 0),
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getGradeByEnrollment(int enrollmentId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'grades',
      where: 'enrollment_id = ?',
      whereArgs: [enrollmentId],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getGradeById(int gradeId) async {
    final db = await _dbHelper.database;
    final maps = await db.rawQuery('''
      SELECT g.*, s.name as student_name, c.title as course_title
      FROM grades g
      JOIN students s ON g.student_id = s.id
      JOIN courses c ON g.course_id = c.id
      WHERE g.id = ?
    ''', [gradeId]);
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<int> updateGrade(Grade grade) async {
    final db = await _dbHelper.database;
    return await db.update(
      'grades',
      grade.toMap(),
      where: 'id = ?',
      whereArgs: [grade.id],
    );
  }

  Future<int> deleteGrade(int gradeId) async {
    final db = await _dbHelper.database;
    
    try {
      // First, get the grade to retrieve enrollment_id
      final grade = await getGradeById(gradeId);
      if (grade == null) {
        throw Exception('Grade not found');
      }
      
      final enrollmentId = grade['enrollment_id'] as int?;
      
      // Delete the grade
      final result = await db.delete(
        'grades',
        where: 'id = ?',
        whereArgs: [gradeId],
      );
      
      // If grade was deleted and we have enrollment_id, update enrollment status
      if (result > 0 && enrollmentId != null) {
        await updateEnrollmentStatus(enrollmentId, 'enrolled');
      }
      
      return result;
    } catch (e) {
      print('Error deleting grade: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllGradesWithDetails() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        g.id,
        g.marks,
        g.grade,
        g.semester,
        g.created_at,
        s.name as student_name,
        s.student_id as student_code,
        c.title as course_title,
        c.course_code,
        c.credits
      FROM grades g
      JOIN students s ON g.student_id = s.id
      JOIN courses c ON g.course_id = c.id
      ORDER BY g.created_at DESC
    ''');
  }

  // ================================
  // DASHBOARD & STATISTICS
  // ================================
  
  Future<Map<String, int>> getDashboardStats() async {
    final db = await _dbHelper.database;
    
    try {
      // Count students
      final studentResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM students'
      );
      final studentCount = _safeCast<int>(
        studentResult.first['count'],
        0
      );
      
      // Count courses
      final courseResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM courses'
      );
      final courseCount = _safeCast<int>(
        courseResult.first['count'],
        0
      );
      
      // Count active enrollments
      final enrollmentResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM enrollments WHERE status = "enrolled"'
      );
      final enrollmentCount = _safeCast<int>(
        enrollmentResult.first['count'],
        0
      );
      
      print('Dashboard Stats - Students: $studentCount, Courses: $courseCount, Enrollments: $enrollmentCount');
      
      return {
        'students': studentCount,
        'courses': courseCount,
        'enrollments': enrollmentCount,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'students': 0,
        'courses': 0,
        'enrollments': 0,
      };
    }
  }

  // Enhanced statistics
  Future<Map<String, dynamic>> getEnhancedStats() async {
    final db = await _dbHelper.database;
    
    try {
      // Total students
      final studentResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM students'
      );
      final totalStudents = _safeCast<int>(studentResult.first['count'], 0);
      
      // Total courses
      final courseResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM courses'
      );
      final totalCourses = _safeCast<int>(courseResult.first['count'], 0);
      
      // Total enrollments
      final enrollmentResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM enrollments'
      );
      final totalEnrollments = _safeCast<int>(enrollmentResult.first['count'], 0);
      
      // Active enrollments
      final activeEnrollmentsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM enrollments WHERE status = "enrolled"'
      );
      final activeEnrollments = _safeCast<int>(activeEnrollmentsResult.first['count'], 0);
      
      // Completed enrollments
      final completedEnrollmentsResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM enrollments WHERE status = "completed"'
      );
      final completedEnrollments = _safeCast<int>(completedEnrollmentsResult.first['count'], 0);
      
      // Total grades
      final gradesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM grades'
      );
      final totalGrades = _safeCast<int>(gradesResult.first['count'], 0);
      
      return {
        'totalStudents': totalStudents,
        'totalCourses': totalCourses,
        'totalEnrollments': totalEnrollments,
        'activeEnrollments': activeEnrollments,
        'completedEnrollments': completedEnrollments,
        'totalGrades': totalGrades,
      };
    } catch (e) {
      print('Error getting enhanced stats: $e');
      return {
        'totalStudents': 0,
        'totalCourses': 0,
        'totalEnrollments': 0,
        'activeEnrollments': 0,
        'completedEnrollments': 0,
        'totalGrades': 0,
      };
    }
  }

  // Student Performance
  Future<List<Map<String, dynamic>>> getStudentPerformance(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.course_code,
        c.title,
        g.marks,
        g.grade,
        g.semester,
        c.credits,
        CASE 
          WHEN g.marks >= 90 THEN 'Excellent'
          WHEN g.marks >= 80 THEN 'Good'
          WHEN g.marks >= 70 THEN 'Average'
          WHEN g.marks >= 60 THEN 'Below Average'
          ELSE 'Poor'
        END as performance
      FROM grades g
      JOIN courses c ON g.course_id = c.id
      WHERE g.student_id = ?
      ORDER BY g.semester DESC, c.title ASC
    ''', [studentId]);
    
    return maps.map((map) {
      return {
        'course_code': _safeCast<String>(map['course_code'], ''),
        'title': _safeCast<String>(map['title'], ''),
        'marks': _safeCast<double>(map['marks'], 0.0),
        'grade': _safeCast<String>(map['grade'], ''),
        'semester': _safeCast<String>(map['semester'], ''),
        'credits': _safeCast<int>(map['credits'], 0),
        'performance': _safeCast<String>(map['performance'], ''),
      };
    }).toList();
  }

  // Course Statistics
  Future<Map<String, dynamic>> getCourseStatistics(int courseId) async {
    final db = await _dbHelper.database;
    
    try {
      final enrollmentCountResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM enrollments WHERE course_id = ? AND status = "enrolled"',
        [courseId]
      );
      final enrollmentCount = _safeCast<int>(enrollmentCountResult.first['count'], 0);
      
      final gradeStatsResult = await db.rawQuery('''
        SELECT 
          AVG(marks) as avg_marks,
          COUNT(*) as total_grades,
          SUM(CASE WHEN grade = "A" THEN 1 ELSE 0 END) as grade_a,
          SUM(CASE WHEN grade = "B" THEN 1 ELSE 0 END) as grade_b,
          SUM(CASE WHEN grade = "C" THEN 1 ELSE 0 END) as grade_c,
          SUM(CASE WHEN grade = "D" THEN 1 ELSE 0 END) as grade_d,
          SUM(CASE WHEN grade = "F" THEN 1 ELSE 0 END) as grade_f
        FROM grades
        WHERE course_id = ?
      ''', [courseId]);
      
      final gradeStats = gradeStatsResult.first;
      
      return {
        'enrollments': enrollmentCount,
        'avg_marks': _safeCast<double>(gradeStats['avg_marks'], 0.0),
        'total_grades': _safeCast<int>(gradeStats['total_grades'], 0),
        'grade_distribution': {
          'A': _safeCast<int>(gradeStats['grade_a'], 0),
          'B': _safeCast<int>(gradeStats['grade_b'], 0),
          'C': _safeCast<int>(gradeStats['grade_c'], 0),
          'D': _safeCast<int>(gradeStats['grade_d'], 0),
          'F': _safeCast<int>(gradeStats['grade_f'], 0),
        }
      };
    } catch (e) {
      print('Error getting course statistics: $e');
      return {
        'enrollments': 0,
        'avg_marks': 0.0,
        'total_grades': 0,
        'grade_distribution': {
          'A': 0,
          'B': 0,
          'C': 0,
          'D': 0,
          'F': 0,
        }
      };
    }
  }

  // Top Performing Students
  Future<List<Map<String, dynamic>>> getTopPerformingStudents() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        s.student_id,
        s.name,
        s.department,
        AVG(
          CASE g.grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
            ELSE 0.0
          END
        ) as gpa,
        COUNT(g.id) as courses_completed
      FROM students s
      LEFT JOIN grades g ON s.id = g.student_id
      GROUP BY s.id
      HAVING courses_completed > 0
      ORDER BY gpa DESC
      LIMIT 10
    ''');
    
    return maps.map((map) {
      final gpaValue = map['gpa'];
      double gpa = 0.0;
      if (gpaValue != null && gpaValue is num) {
        gpa = gpaValue.toDouble();
      }
      
      return {
        'student_id': _safeCast<String>(map['student_id'], ''),
        'name': _safeCast<String>(map['name'], ''),
        'department': _safeCast<String>(map['department'], ''),
        'gpa': gpa,
        'courses_completed': _safeCast<int>(map['courses_completed'], 0),
      };
    }).toList();
  }

  // Get Student GPA
  Future<double> getStudentGPA(int studentId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT AVG(
        CASE g.grade
          WHEN 'A' THEN 4.0
          WHEN 'B' THEN 3.0
          WHEN 'C' THEN 2.0
          WHEN 'D' THEN 1.0
          WHEN 'F' THEN 0.0
          ELSE 0.0
        END
      ) as gpa
      FROM grades g
      WHERE g.student_id = ?
    ''', [studentId]);
    
    final gpaValue = result.first['gpa'];
    if (gpaValue == null) return 0.0;
    return (gpaValue as num).toDouble();
  }

  // Search students
  Future<List<Student>> searchStudents(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM students 
      WHERE name LIKE ? OR student_id LIKE ? OR email LIKE ? OR department LIKE ?
    ''', ['%$query%', '%$query%', '%$query%', '%$query%']);
    
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  // Search courses
  Future<List<Course>> searchCourses(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM courses 
      WHERE title LIKE ? OR course_code LIKE ? OR instructor LIKE ? OR department LIKE ?
    ''', ['%$query%', '%$query%', '%$query%', '%$query%']);
    
    return List.generate(maps.length, (i) => Course.fromMap(maps[i]));
  }

  // Check if student is enrolled in course
  Future<bool> isStudentEnrolled(int studentId, int courseId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM enrollments WHERE student_id = ? AND course_id = ?',
      [studentId, courseId]
    );
    return _safeCast<int>(result.first['count'], 0) > 0;
  }

  // Get available courses for student (courses not enrolled)
  Future<List<Course>> getAvailableCoursesForStudent(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM courses 
      WHERE id NOT IN (
        SELECT course_id FROM enrollments WHERE student_id = ?
      )
    ''', [studentId]);
    
    return List.generate(maps.length, (i) => Course.fromMap(maps[i]));
  }

  // Get semester-wise grades for a student
  Future<Map<String, List<Map<String, dynamic>>>> getGradesBySemester(int studentId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        g.semester,
        c.title,
        g.marks,
        g.grade,
        c.credits
      FROM grades g
      JOIN courses c ON g.course_id = c.id
      WHERE g.student_id = ?
      ORDER BY g.semester DESC, c.title ASC
    ''', [studentId]);
    
    Map<String, List<Map<String, dynamic>>> result = {};
    
    for (var map in maps) {
      final semester = _safeCast<String>(map['semester'], 'Unknown');
      if (!result.containsKey(semester)) {
        result[semester] = [];
      }
      result[semester]!.add({
        'title': _safeCast<String>(map['title'], ''),
        'marks': _safeCast<double>(map['marks'], 0.0),
        'grade': _safeCast<String>(map['grade'], ''),
        'credits': _safeCast<int>(map['credits'], 0),
      });
    }
    
    return result;
  }

  // Get grade distribution for all courses
  Future<Map<String, Map<String, int>>> getGradeDistribution() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.course_code,
        c.title,
        g.grade,
        COUNT(*) as count
      FROM grades g
      JOIN courses c ON g.course_id = c.id
      GROUP BY c.course_code, g.grade
      ORDER BY c.course_code, g.grade
    ''');
    
    Map<String, Map<String, int>> result = {};
    
    for (var map in maps) {
      final courseCode = _safeCast<String>(map['course_code'], 'Unknown');
      final grade = _safeCast<String>(map['grade'], '');
      final count = _safeCast<int>(map['count'], 0);
      
      if (!result.containsKey(courseCode)) {
        result[courseCode] = {};
      }
      result[courseCode]![grade] = count;
    }
    
    return result;
  }

  // Close database
  Future<void> close() async {
    await _dbHelper.close();
  }
}