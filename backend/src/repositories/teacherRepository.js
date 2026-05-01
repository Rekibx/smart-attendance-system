const pool = require('../config/db');

async function listStudents({ departmentId, semesterId }) {
  const [rows] = await pool.execute(
    `SELECT student_id, student_name, roll_no, email, department_id, semester_id
     FROM students
     WHERE department_id = :departmentId AND semester_id = :semesterId
     ORDER BY roll_no, student_name`,
    { departmentId, semesterId }
  );
  return rows;
}

async function ensureSubjectInScope({ subjectId, departmentId, semesterId }) {
  const [rows] = await pool.execute(
    `SELECT subject_id
     FROM subjects
     WHERE subject_id = :subjectId
       AND department_id = :departmentId
       AND semester_id = :semesterId
     LIMIT 1`,
    { subjectId, departmentId, semesterId }
  );
  return Boolean(rows[0]);
}

async function subjectExists(subjectId) {
  const [rows] = await pool.execute(
    'SELECT subject_id FROM subjects WHERE subject_id = :subjectId LIMIT 1',
    { subjectId }
  );
  return Boolean(rows[0]);
}

async function countStudentsByIds(studentIds) {
  if (studentIds.length === 0) {
    return 0;
  }

  const placeholders = studentIds.map((_, index) => `:studentId${index}`).join(', ');
  const params = Object.fromEntries(
    studentIds.map((studentId, index) => [`studentId${index}`, studentId])
  );
  const [rows] = await pool.execute(
    `SELECT COUNT(*) AS total FROM students WHERE student_id IN (${placeholders})`,
    params
  );
  return Number(rows[0].total);
}

async function upsertAttendance({ subjectId, attendanceDate, markedBy, records }) {
  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    for (const record of records) {
      await connection.execute(
        `INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by)
         VALUES (:studentId, :subjectId, :attendanceDate, :status, :markedBy)
         ON DUPLICATE KEY UPDATE
           status = VALUES(status),
           marked_by = VALUES(marked_by),
           updated_at = CURRENT_TIMESTAMP`,
        {
          studentId: record.studentId,
          subjectId,
          attendanceDate,
          status: record.status,
          markedBy
        }
      );
    }

    await connection.commit();
  } catch (error) {
    await connection.rollback();
    throw error;
  } finally {
    connection.release();
  }
}

async function getAttendance({ subjectId, attendanceDate }) {
  const params = { subjectId };
  const where = ['a.subject_id = :subjectId'];

  if (attendanceDate) {
    where.push('a.attendance_date = :attendanceDate');
    params.attendanceDate = attendanceDate;
  }

  const [rows] = await pool.execute(
    `SELECT a.attendance_id, a.attendance_date, a.status,
            s.student_id, s.student_name, s.roll_no,
            sub.subject_id, sub.subject_name,
            u.user_id AS marked_by, u.name AS marked_by_name
     FROM attendance a
     JOIN students s ON s.student_id = a.student_id
     JOIN subjects sub ON sub.subject_id = a.subject_id
     JOIN users u ON u.user_id = a.marked_by
     WHERE ${where.join(' AND ')}
     ORDER BY a.attendance_date DESC, s.roll_no, s.student_name`,
    params
  );
  return rows;
}

module.exports = {
  listStudents,
  ensureSubjectInScope,
  subjectExists,
  countStudentsByIds,
  upsertAttendance,
  getAttendance
};
