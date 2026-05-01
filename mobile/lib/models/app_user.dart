class AppUser {
  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.student,
  });

  final int userId;
  final String name;
  final String email;
  final String role;
  final StudentProfile? student;

  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      userId: json['userId'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      student: json['student'] == null
          ? null
          : StudentProfile.fromJson(json['student'] as Map<String, dynamic>),
    );
  }
}

class StudentProfile {
  StudentProfile({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.departmentName,
    required this.semesterNo,
  });

  final int studentId;
  final String studentName;
  final String rollNo;
  final String departmentName;
  final int semesterNo;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      studentId: json['student_id'] as int,
      studentName: json['student_name'] as String,
      rollNo: json['roll_no'] as String,
      departmentName: json['department_name'] as String,
      semesterNo: json['semester_no'] as int,
    );
  }
}
