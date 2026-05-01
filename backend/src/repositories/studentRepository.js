const pool = require('../config/db');

async function getAttendance(studentId) {
  const [rows] = await pool.execute(
    `SELECT a.attendance_id, a.attendance_date, a.status,
            sub.subject_id, sub.subject_name
     FROM attendance a
     JOIN subjects sub ON sub.subject_id = a.subject_id
     WHERE a.student_id = :studentId
     ORDER BY a.attendance_date DESC, sub.subject_name`,
    { studentId }
  );
  return rows;
}

async function getSummary(studentId) {
  const [rows] = await pool.execute(
    `SELECT sub.subject_id, sub.subject_name,
            COUNT(a.attendance_id) AS total_classes,
            SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) AS present_classes,
            ROUND(
              CASE
                WHEN COUNT(a.attendance_id) = 0 THEN 0
                ELSE SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) * 100 / COUNT(a.attendance_id)
              END,
              2
            ) AS percentage
     FROM attendance a
     JOIN subjects sub ON sub.subject_id = a.subject_id
     WHERE a.student_id = :studentId
     GROUP BY sub.subject_id, sub.subject_name
     ORDER BY sub.subject_name`,
    { studentId }
  );
  return rows;
}

module.exports = { getAttendance, getSummary };
