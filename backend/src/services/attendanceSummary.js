function calculateAttendanceSummary(records) {
  const bySubject = new Map();

  for (const record of records) {
    const current = bySubject.get(record.subject_id) || {
      subject_id: record.subject_id,
      subject_name: record.subject_name,
      total_classes: 0,
      present_classes: 0,
      percentage: 0
    };

    current.total_classes += 1;
    if (record.status === 'present') {
      current.present_classes += 1;
    }
    current.percentage = Number(
      ((current.present_classes * 100) / current.total_classes).toFixed(2)
    );
    bySubject.set(record.subject_id, current);
  }

  return [...bySubject.values()].sort((a, b) =>
    a.subject_name.localeCompare(b.subject_name)
  );
}

module.exports = { calculateAttendanceSummary };
