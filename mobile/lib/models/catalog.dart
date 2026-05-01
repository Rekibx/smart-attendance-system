class Department {
  Department({required this.id, required this.name});

  final int id;
  final String name;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['department_id'] as int,
      name: json['name'] as String,
    );
  }
}

class Semester {
  Semester({required this.id, required this.number});

  final int id;
  final int number;

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      id: json['semester_id'] as int,
      number: json['semester_no'] as int,
    );
  }
}

class Subject {
  Subject({
    required this.id,
    required this.name,
    required this.departmentId,
    required this.semesterId,
  });

  final int id;
  final String name;
  final int departmentId;
  final int semesterId;

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['subject_id'] as int,
      name: json['subject_name'] as String,
      departmentId: json['department_id'] as int,
      semesterId: json['semester_id'] as int,
    );
  }
}
