const pool = require('../config/db');

async function findByEmail(email) {
  const [rows] = await pool.execute(
    `SELECT user_id, name, email, password, role, created_at
     FROM users
     WHERE email = :email
     LIMIT 1`,
    { email }
  );
  return rows[0] || null;
}

async function findStudentProfileByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT s.student_id, s.student_name, s.roll_no, s.email,
            d.department_id, d.name AS department_name,
            sem.semester_id, sem.semester_no
     FROM students s
     JOIN departments d ON d.department_id = s.department_id
     JOIN semesters sem ON sem.semester_id = s.semester_id
     WHERE s.user_id = :userId
     LIMIT 1`,
    { userId }
  );
  return rows[0] || null;
}

module.exports = { findByEmail, findStudentProfileByUserId };
