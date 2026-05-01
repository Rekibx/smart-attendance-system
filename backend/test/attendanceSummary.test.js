const test = require('node:test');
const assert = require('node:assert/strict');
const { calculateAttendanceSummary } = require('../src/services/attendanceSummary');

test('calculates subject-wise attendance percentage', () => {
  const summary = calculateAttendanceSummary([
    { subject_id: 2, subject_name: 'Web Technology', status: 'present' },
    { subject_id: 1, subject_name: 'Database Management System', status: 'present' },
    { subject_id: 1, subject_name: 'Database Management System', status: 'absent' },
    { subject_id: 1, subject_name: 'Database Management System', status: 'present' }
  ]);

  assert.deepEqual(summary, [
    {
      subject_id: 1,
      subject_name: 'Database Management System',
      total_classes: 3,
      present_classes: 2,
      percentage: 66.67
    },
    {
      subject_id: 2,
      subject_name: 'Web Technology',
      total_classes: 1,
      present_classes: 1,
      percentage: 100
    }
  ]);
});

test('returns an empty summary when no attendance exists', () => {
  assert.deepEqual(calculateAttendanceSummary([]), []);
});
