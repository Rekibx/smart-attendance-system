# Smart Attendance Backend

REST API for the Smart Attendance Management System.

## Setup

1. Create a MySQL database with `database/schema.sql`.
2. Insert demo data with `database/seed.sql`.
3. Copy `.env.example` to `.env` and update credentials.
4. Install dependencies:

```bash
npm.cmd install
```

5. Start the API:

```bash
npm.cmd run dev
```

## Demo Accounts

- Teacher: `teacher@ustm.edu` / `password123`
- Student: `rikib@student.ustm.edu` / `password123`
- Student: `monimul@student.ustm.edu` / `password123`
- Student: `azizul@student.ustm.edu` / `password123`

## API Overview

- `POST /auth/login`
- `GET /catalog/departments`
- `GET /catalog/semesters`
- `GET /catalog/subjects`
- `GET /teacher/students?departmentId=1&semesterId=1&subjectId=1`
- `POST /teacher/attendance`
- `GET /teacher/attendance?subjectId=1&date=2026-04-29`
- `GET /student/attendance`
- `GET /student/attendance/summary`
