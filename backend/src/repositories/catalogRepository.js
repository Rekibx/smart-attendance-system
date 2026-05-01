const pool = require('../config/db');

async function listDepartments() {
  const [rows] = await pool.execute(
    'SELECT department_id, name FROM departments ORDER BY name'
  );
  return rows;
}

async function listSemesters() {
  const [rows] = await pool.execute(
    'SELECT semester_id, semester_no FROM semesters ORDER BY semester_no'
  );
  return rows;
}

async function listSubjects(filters = {}) {
  const params = {};
  const where = [];

  if (filters.departmentId) {
    where.push('department_id = :departmentId');
    params.departmentId = filters.departmentId;
  }

  if (filters.semesterId) {
    where.push('semester_id = :semesterId');
    params.semesterId = filters.semesterId;
  }

  const [rows] = await pool.execute(
    `SELECT subject_id, subject_name, department_id, semester_id
     FROM subjects
     ${where.length ? `WHERE ${where.join(' AND ')}` : ''}
     ORDER BY subject_name`,
    params
  );
  return rows;
}

module.exports = { listDepartments, listSemesters, listSubjects };
