USE smart_attendance;

INSERT INTO departments (department_id, name) VALUES
  (1, 'Computer Science')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO semesters (semester_id, semester_no) VALUES
  (1, 4)
ON DUPLICATE KEY UPDATE semester_no = VALUES(semester_no);

-- Demo password for all users: password123
INSERT INTO users (user_id, name, email, password, role) VALUES
  (1, 'Ms. Sangeeta Borkakoty', 'teacher@ustm.edu', '$2a$10$eqrdCh4HXjnQ4zvi/brPh.elpRNYnYPY9Huo0sf/9OVPqpyno0tty', 'teacher'),
  (2, 'Rikib Uddin Ahmed', 'rikib@student.ustm.edu', '$2a$10$eqrdCh4HXjnQ4zvi/brPh.elpRNYnYPY9Huo0sf/9OVPqpyno0tty', 'student'),
  (3, 'Monimul Hoque', 'monimul@student.ustm.edu', '$2a$10$eqrdCh4HXjnQ4zvi/brPh.elpRNYnYPY9Huo0sf/9OVPqpyno0tty', 'student'),
  (4, 'Azizul Khan', 'azizul@student.ustm.edu', '$2a$10$eqrdCh4HXjnQ4zvi/brPh.elpRNYnYPY9Huo0sf/9OVPqpyno0tty', 'student')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  email = VALUES(email),
  password = VALUES(password),
  role = VALUES(role);

INSERT INTO students (student_id, user_id, student_name, roll_no, department_id, semester_id, email) VALUES
  (1, 2, 'Rikib Uddin Ahmed', 'BCA-2024-001', 1, 1, 'rikib@student.ustm.edu'),
  (2, 3, 'Monimul Hoque', 'BCA-2024-002', 1, 1, 'monimul@student.ustm.edu'),
  (3, 4, 'Azizul Khan', 'BCA-2024-003', 1, 1, 'azizul@student.ustm.edu')
ON DUPLICATE KEY UPDATE
  user_id = VALUES(user_id),
  student_name = VALUES(student_name),
  roll_no = VALUES(roll_no),
  department_id = VALUES(department_id),
  semester_id = VALUES(semester_id),
  email = VALUES(email);

INSERT INTO subjects (subject_id, subject_name, department_id, semester_id) VALUES
  (1, 'Database Management System', 1, 1),
  (2, 'Web Technology', 1, 1),
  (3, 'Software Engineering', 1, 1)
ON DUPLICATE KEY UPDATE
  subject_name = VALUES(subject_name),
  department_id = VALUES(department_id),
  semester_id = VALUES(semester_id);

INSERT INTO attendance (student_id, subject_id, attendance_date, status, marked_by) VALUES
  (1, 1, '2026-04-29', 'present', 1),
  (2, 1, '2026-04-29', 'present', 1),
  (3, 1, '2026-04-29', 'absent', 1)
ON DUPLICATE KEY UPDATE
  status = VALUES(status),
  marked_by = VALUES(marked_by);
