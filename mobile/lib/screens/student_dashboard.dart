import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/attendance.dart';
import '../providers/app_state.dart';
import '../services/api_client.dart';
import '../widgets/app_scaffold.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<AttendanceSummary> _summary = [];
  List<AttendanceRecord> _records = [];
  bool _loading = true;

  ApiClient get _api => context.read<AppState>().apiClient;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final summary = await _api.getStudentSummary();
      final records = await _api.getStudentAttendance();
      setState(() {
        _summary = summary;
        _records = records;
      });
    } catch (error) {
      if (!mounted) return;
      final message = error is ApiException ? error.message : 'Unable to load attendance';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    final profile = user?.student;

    return AppScaffold(
      title: 'Student Dashboard',
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (profile != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(profile.studentName),
                  subtitle: Text('${profile.rollNo} • Semester ${profile.semesterNo}'),
                ),
              ),
            const SizedBox(height: 16),
            if (_loading) const LinearProgressIndicator(),
            Text('Subject Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_summary.isEmpty && !_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No attendance summary is available yet.'),
              )
            else
              ..._summary.map(_SummaryTile.new),
            const SizedBox(height: 24),
            Text('Attendance History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_records.isEmpty && !_loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No attendance records are available yet.'),
              )
            else
              ..._records.map(
                (record) => ListTile(
                  leading: Icon(
                    record.isPresent ? Icons.check_circle : Icons.cancel,
                    color: record.isPresent ? Colors.green : Colors.red,
                  ),
                  title: Text(record.subjectName),
                  subtitle: Text(record.date),
                  trailing: Text(record.status.toUpperCase()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile(this.summary);

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final color = summary.percentage >= 75 ? Colors.green : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    summary.subjectName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${summary.percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: summary.percentage / 100,
              color: color,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text('${summary.presentClasses}/${summary.totalClasses} classes attended'),
          ],
        ),
      ),
    );
  }
}
