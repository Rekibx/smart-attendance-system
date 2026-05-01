import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/app_user.dart';
import '../models/attendance.dart';
import '../models/catalog.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LoginResult {
  LoginResult({required this.token, required this.user});

  final String token;
  final AppUser user;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${AppConfig.apiBaseUrl}$path').replace(queryParameters: query);
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<dynamic> _decode(http.Response response) async {
    final body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(body['message'] as String? ?? 'Something went wrong');
    }

    return body;
  }

  Future<LoginResult> login(String email, String password) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = await _decode(response) as Map<String, dynamic>;
    final token = body['token'] as String;
    setToken(token);
    return LoginResult(
      token: token,
      user: AppUser.fromJson(body['user'] as Map<String, dynamic>),
    );
  }

  Future<List<Department>> getDepartments() async {
    final response = await _client.get(_uri('/catalog/departments'), headers: _headers);
    final body = await _decode(response) as Map<String, dynamic>;
    return (body['departments'] as List)
        .map((item) => Department.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Semester>> getSemesters() async {
    final response = await _client.get(_uri('/catalog/semesters'), headers: _headers);
    final body = await _decode(response) as Map<String, dynamic>;
    return (body['semesters'] as List)
        .map((item) => Semester.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Subject>> getSubjects({int? departmentId, int? semesterId}) async {
    final query = <String, String>{
      if (departmentId != null) 'departmentId': '$departmentId',
      if (semesterId != null) 'semesterId': '$semesterId',
    };
    final response = await _client.get(_uri('/catalog/subjects', query), headers: _headers);
    final body = await _decode(response) as Map<String, dynamic>;
    return (body['subjects'] as List)
        .map((item) => Subject.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Student>> getTeacherStudents({
    required int departmentId,
    required int semesterId,
    required int subjectId,
  }) async {
    final response = await _client.get(
      _uri('/teacher/students', {
        'departmentId': '$departmentId',
        'semesterId': '$semesterId',
        'subjectId': '$subjectId',
      }),
      headers: _headers,
    );
    final body = await _decode(response) as Map<String, dynamic>;
    return (body['students'] as List)
        .map((item) => Student.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAttendance({
    required int subjectId,
    required DateTime date,
    required Map<int, String> statuses,
  }) async {
    final response = await _client.post(
      _uri('/teacher/attendance'),
      headers: _headers,
      body: jsonEncode({
        'subjectId': subjectId,
        'date': date.toIso8601String().substring(0, 10),
        'records': statuses.entries
            .map((entry) => {'studentId': entry.key, 'status': entry.value})
            .toList(),
      }),
    );
    await _decode(response);
  }

  Future<List<AttendanceRecord>> getTeacherAttendance({
    required int subjectId,
    String? date,
  }) async {
    final response = await _client.get(
      _uri('/teacher/attendance', {
        'subjectId': '$subjectId',
        if (date != null) 'date': date,
      }),
      headers: _headers,
    );
    final body = await _decode(response) as Map<String, dynamic>;
    return (body['attendance'] as List)
        .map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceRecord>> getStudentAttendance() async {
    final response = await _client.get(_uri('/student/attendance'), headers: _headers);
    final body = await _decode(response) as Map<String, dynamic>;
    return (body['attendance'] as List)
        .map((item) => AttendanceRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<AttendanceSummary>> getStudentSummary() async {
    final response = await _client.get(_uri('/student/attendance/summary'), headers: _headers);
    final body = await _decode(response) as Map<String, dynamic>;
    return (body['summary'] as List)
        .map((item) => AttendanceSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
