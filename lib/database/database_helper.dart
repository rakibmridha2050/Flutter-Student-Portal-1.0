import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'college_erp.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Students table
    await db.execute('''
      CREATE TABLE students(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        department TEXT NOT NULL,
        enrollment_date TEXT NOT NULL,
        address TEXT
      )
    ''');

    // Courses table
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_code TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        department TEXT NOT NULL,
        credits INTEGER NOT NULL,
        instructor TEXT NOT NULL,
        max_students INTEGER NOT NULL,
        semester TEXT NOT NULL
      )
    ''');

    // Enrollments table
    await db.execute('''
      CREATE TABLE enrollments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        enrollment_date TEXT NOT NULL,
        status TEXT DEFAULT 'enrolled',
        FOREIGN KEY (student_id) REFERENCES students (id),
        FOREIGN KEY (course_id) REFERENCES courses (id),
        UNIQUE(student_id, course_id)
      )
    ''');

    // Grades table
    await db.execute('''
      CREATE TABLE grades(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        enrollment_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        marks REAL NOT NULL,
        grade TEXT NOT NULL,
        semester TEXT NOT NULL,
        FOREIGN KEY (enrollment_id) REFERENCES enrollments (id),
        FOREIGN KEY (student_id) REFERENCES students (id),
        FOREIGN KEY (course_id) REFERENCES courses (id)
      )
    ''');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
    }
  }

  // Add these methods to the DatabaseHelper class

  Future<List<Map<String, dynamic>>> getStudentEnrollments(
    int studentId,
  ) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT e.*, c.title, c.course_code
    FROM enrollments e
    JOIN courses c ON e.course_id = c.id
    WHERE e.student_id = ?
    ORDER BY e.enrollment_date DESC
  ''',
      [studentId],
    );
  }

  Future<List<Map<String, dynamic>>> getCourseEnrollments(int courseId) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT e.*, s.name, s.student_id
    FROM enrollments e
    JOIN students s ON e.student_id = s.id
    WHERE e.course_id = ?
    ORDER BY e.enrollment_date DESC
  ''',
      [courseId],
    );
  }

  Future<double> getStudentGPA(int studentId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
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
    ''',
      [studentId],
    );

    // Fix: Cast to double properly
    final gpaValue = result.first['gpa'];
    if (gpaValue == null) return 0.0;
    return (gpaValue as num).toDouble();
  }

  // Add these methods to your existing DatabaseHelper class

  Future<Map<String, dynamic>?> getCourse(int courseId) async {
    final db = await database;
    final result = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [courseId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getStudent(int studentId) async {
    final db = await database;
    final result = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [studentId],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getStudentsForGrading(int courseId) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT s.id, s.student_id, s.name, s.department,
           e.id as enrollment_id, g.marks, g.grade
    FROM enrollments e
    JOIN students s ON e.student_id = s.id
    LEFT JOIN grades g ON e.id = g.enrollment_id
    WHERE e.course_id = ? AND e.status = 'enrolled'
    ORDER BY s.name
  ''',
      [courseId],
    );
  }

  Future<void> saveOrUpdateGrade({
    required int enrollmentId,
    required int studentId,
    required int courseId,
    required double marks,
    required String grade,
    required String semester,
  }) async {
    final db = await database;

    // Check if grade already exists
    final existingGrade = await db.query(
      'grades',
      where: 'enrollment_id = ?',
      whereArgs: [enrollmentId],
    );

    if (existingGrade.isNotEmpty) {
      // Update existing grade
      await db.update(
        'grades',
        {'marks': marks, 'grade': grade, 'semester': semester},
        where: 'enrollment_id = ?',
        whereArgs: [enrollmentId],
      );
    } else {
      // Insert new grade
      await db.insert('grades', {
        'enrollment_id': enrollmentId,
        'student_id': studentId,
        'course_id': courseId,
        'marks': marks,
        'grade': grade,
        'semester': semester,
      });
    }
  }

  Future<Map<String, dynamic>> getCourseStatistics(int courseId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT 
      COUNT(DISTINCT g.student_id) as graded_students,
      AVG(g.marks) as average_marks,
      COUNT(CASE WHEN g.grade = 'A' THEN 1 END) as a_grades,
      COUNT(CASE WHEN g.grade = 'B' THEN 1 END) as b_grades,
      COUNT(CASE WHEN g.grade = 'C' THEN 1 END) as c_grades,
      COUNT(CASE WHEN g.grade = 'D' THEN 1 END) as d_grades,
      COUNT(CASE WHEN g.grade = 'F' THEN 1 END) as f_grades
    FROM grades g
    WHERE g.course_id = ?
  ''',
      [courseId],
    );

    return result.isNotEmpty
        ? result.first
        : {
            'graded_students': 0,
            'average_marks': 0.0,
            'a_grades': 0,
            'b_grades': 0,
            'c_grades': 0,
            'd_grades': 0,
            'f_grades': 0,
          };
  }

  // Add these to your existing DatabaseHelper class

  Future<List<Map<String, dynamic>>> getCoursesByInstructor(
    String instructorName,
  ) async {
    final db = await database;
    return await db.query(
      'courses',
      where: 'instructor = ?',
      whereArgs: [instructorName],
      orderBy: 'semester DESC, title ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getStudentCourses(int studentId) async {
    final db = await database;
    return await db.rawQuery(
      '''
    SELECT DISTINCT c.*, g.marks, g.grade
    FROM enrollments e
    JOIN courses c ON e.course_id = c.id
    LEFT JOIN grades g ON e.id = g.enrollment_id AND g.student_id = ?
    WHERE e.student_id = ?
    ORDER BY c.semester DESC
  ''',
      [studentId, studentId],
    );
  }

  Future<Map<String, dynamic>> getGradeSummary(
    int studentId,
    int courseId,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
    SELECT g.*, c.title, c.course_code
    FROM grades g
    JOIN courses c ON g.course_id = c.id
    WHERE g.student_id = ? AND g.course_id = ?
    LIMIT 1
  ''',
      [studentId, courseId],
    );

    return result.isNotEmpty ? result.first : {};
  }
}
