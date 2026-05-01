class Student {
  Student({
    required this.id,
    required this.name,
    required this.rollNo,
    this.email,
  });

  final int id;
  final String name;
  final String rollNo;
  final String? email;

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['student_id'] as int,
      name: json['student_name'] as String,
      rollNo: json['roll_no'] as String,
      email: json['email'] as String?,
    );
  }
}

class AttendanceRecord {
  AttendanceRecord({
    required this.subjectName,
    required this.date,
    required this.status,
    this.studentName,
    this.rollNo,
  });

  final String subjectName;
  final String date;
  final String status;
  final String? studentName;
  final String? rollNo;

  bool get isPresent => status == 'present';

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      subjectName: json['subject_name'] as String,
      date: (json['attendance_date'] as String).substring(0, 10),
      status: json['status'] as String,
      studentName: json['student_name'] as String?,
      rollNo: json['roll_no'] as String?,
    );
  }
}

class AttendanceSummary {
  AttendanceSummary({
    required this.subjectName,
    required this.totalClasses,
    required this.presentClasses,
    required this.percentage,
  });

  final String subjectName;
  final int totalClasses;
  final int presentClasses;
  final double percentage;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      subjectName: json['subject_name'] as String,
      totalClasses: (json['total_classes'] as num).toInt(),
      presentClasses: (json['present_classes'] as num).toInt(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
}
