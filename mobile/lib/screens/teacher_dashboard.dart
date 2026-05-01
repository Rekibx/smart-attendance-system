import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/attendance.dart';
import '../models/catalog.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../widgets/app_scaffold.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _dateFormat = DateFormat('yyyy-MM-dd');
  List<Department> _departments = [];
  List<Semester> _semesters = [];
  List<Subject> _subjects = [];
  List<Student> _students = [];
  List<AttendanceRecord> _history = [];
  Department? _department;
  Semester? _semester;
  Subject? _subject;
  DateTime _date = DateTime.now();
  bool _loading = true;
  final Map<int, String> _statuses = {};

  ApiClient get _api => context.read<AppState>().apiClient;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    setState(() => _loading = true);
    try {
      final departments = await _api.getDepartments();
      final semesters = await _api.getSemesters();
      final subjects = await _api.getSubjects();
      setState(() {
        _departments = departments;
        _semesters = semesters;
        _subjects = subjects;
        _department = departments.isEmpty ? null : departments.first;
        _semester = semesters.isEmpty ? null : semesters.first;
        _subject = subjects.isEmpty ? null : subjects.first;
      });
      await _loadStudentsAndHistory();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadStudentsAndHistory() async {
    if (_department == null || _semester == null || _subject == null) return;

    final students = await _api.getTeacherStudents(
      departmentId: _department!.id,
      semesterId: _semester!.id,
      subjectId: _subject!.id,
    );
    final history = await _api.getTeacherAttendance(subjectId: _subject!.id);

    setState(() {
      _students = students;
      _history = history;
      _statuses
        ..clear()
        ..addEntries(students.map((student) => MapEntry(student.id, 'present')));
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null) {
      setState(() => _date = selected);
    }
  }

  Future<void> _saveAttendance() async {
    if (_subject == null || _statuses.isEmpty) return;

    setState(() => _loading = true);
    try {
      await _api.saveAttendance(
        subjectId: _subject!.id,
        date: _date,
        statuses: _statuses,
      );
      await _loadStudentsAndHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved successfully')),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    final message = error is ApiException ? error.message : 'Unable to load data';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Teacher Dashboard',
      body: RefreshIndicator(
        onRefresh: _loadStudentsAndHistory,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            _buildAttendanceList(),
            const SizedBox(height: 24),
            _buildHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        DropdownButtonFormField<Department>(
          value: _department,
          decoration: const InputDecoration(labelText: 'Department'),
          items: _departments
              .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
              .toList(),
          onChanged: (value) async {
            setState(() => _department = value);
            await _loadStudentsAndHistory();
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Semester>(
          value: _semester,
          decoration: const InputDecoration(labelText: 'Semester'),
          items: _semesters
              .map((item) => DropdownMenuItem(value: item, child: Text('Semester ${item.number}')))
              .toList(),
          onChanged: (value) async {
            setState(() => _semester = value);
            await _loadStudentsAndHistory();
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<Subject>(
          value: _subject,
          decoration: const InputDecoration(labelText: 'Subject'),
          items: _subjects
              .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
              .toList(),
          onChanged: (value) async {
            setState(() => _subject = value);
            await _loadStudentsAndHistory();
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_month),
          label: Text(_dateFormat.format(_date)),
        ),
      ],
    );
  }

  Widget _buildAttendanceList() {
    if (_students.isEmpty && !_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No students found for the selected class.'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Mark Attendance', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ..._students.map(
          (student) => Card(
            child: ListTile(
              title: Text(student.name),
              subtitle: Text(student.rollNo),
              trailing: SegmentedButton<String>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'present', label: Text('P')),
                  ButtonSegment(value: 'absent', label: Text('A')),
                ],
                selected: {_statuses[student.id] ?? 'present'},
                onSelectionChanged: (value) {
                  setState(() => _statuses[student.id] = value.first);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _students.isEmpty || _loading ? null : _saveAttendance,
          icon: const Icon(Icons.save),
          label: const Text('Save Attendance'),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Records', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (_history.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No attendance records yet.'),
          )
        else
          ..._history.take(10).map(
                (record) => ListTile(
                  leading: Icon(
                    record.isPresent ? Icons.check_circle : Icons.cancel,
                    color: record.isPresent ? Colors.green : Colors.red,
                  ),
                  title: Text('${record.studentName} (${record.rollNo})'),
                  subtitle: Text('${record.subjectName} • ${record.date}'),
                  trailing: Text(record.status.toUpperCase()),
                ),
              ),
      ],
    );
  }
}
