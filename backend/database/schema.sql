CREATE DATABASE IF NOT EXISTS smart_attendance;
USE smart_attendance;

CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(35) NOT NULL,
  email VARCHAR(45) NOT NULL UNIQUE,
  password VARCHAR(270) NOT NULL,
  role ENUM('teacher', 'student') NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS departments (
  department_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS semesters (
  semester_id INT AUTO_INCREMENT PRIMARY KEY,
  semester_no INT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  student_name VARCHAR(35) NOT NULL,
  roll_no VARCHAR(20) NOT NULL UNIQUE,
  department_id INT NOT NULL,
  semester_id INT NOT NULL,
  email VARCHAR(45) UNIQUE,
  CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(user_id),
  CONSTRAINT fk_students_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
  CONSTRAINT fk_students_semester FOREIGN KEY (semester_id) REFERENCES semesters(semester_id)
);

CREATE TABLE IF NOT EXISTS subjects (
  subject_id INT AUTO_INCREMENT PRIMARY KEY,
  subject_name VARCHAR(35) NOT NULL,
  department_id INT NOT NULL,
  semester_id INT NOT NULL,
  CONSTRAINT fk_subjects_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
  CONSTRAINT fk_subjects_semester FOREIGN KEY (semester_id) REFERENCES semesters(semester_id),
  CONSTRAINT uq_subject_scope UNIQUE (subject_name, department_id, semester_id)
);

CREATE TABLE IF NOT EXISTS attendance (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  subject_id INT NOT NULL,
  attendance_date DATE NOT NULL,
  status ENUM('present', 'absent') NOT NULL,
  marked_by INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_attendance_student FOREIGN KEY (student_id) REFERENCES students(student_id),
  CONSTRAINT fk_attendance_subject FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
  CONSTRAINT fk_attendance_marker FOREIGN KEY (marked_by) REFERENCES users(user_id),
  CONSTRAINT uq_attendance_once_per_day UNIQUE (student_id, subject_id, attendance_date)
);
