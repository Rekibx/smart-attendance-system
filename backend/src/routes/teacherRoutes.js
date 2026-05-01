const express = require('express');
const { body, query } = require('express-validator');
const teacherRepository = require('../repositories/teacherRepository');
const { authenticate, authorize } = require('../middleware/auth');
const asyncHandler = require('../utils/asyncHandler');
const HttpError = require('../utils/httpError');
const validate = require('../middleware/validate');

const router = express.Router();

router.use(authenticate, authorize('teacher'));

router.get(
  '/students',
  [
    query('departmentId').isInt({ min: 1 }).withMessage('departmentId is required'),
    query('semesterId').isInt({ min: 1 }).withMessage('semesterId is required'),
    query('subjectId').optional().isInt({ min: 1 }).withMessage('subjectId must be valid')
  ],
  validate,
  asyncHandler(async (req, res) => {
    const departmentId = Number(req.query.departmentId);
    const semesterId = Number(req.query.semesterId);
    const subjectId = req.query.subjectId ? Number(req.query.subjectId) : null;

    if (subjectId) {
      const subjectMatches = await teacherRepository.ensureSubjectInScope({
        subjectId,
        departmentId,
        semesterId
      });

      if (!subjectMatches) {
        throw new HttpError(400, 'Subject does not belong to the selected department and semester');
      }
    }

    res.json({
      students: await teacherRepository.listStudents({ departmentId, semesterId })
    });
  })
);

router.post(
  '/attendance',
  [
    body('subjectId').isInt({ min: 1 }).withMessage('subjectId is required'),
    body('date').isISO8601().toDate().withMessage('Valid attendance date is required'),
    body('records').isArray({ min: 1 }).withMessage('At least one attendance record is required'),
    body('records.*.studentId').isInt({ min: 1 }).withMessage('studentId is required for every record'),
    body('records.*.status').isIn(['present', 'absent']).withMessage('status must be present or absent'),
    body('records').custom((records) => {
      const studentIds = records.map((record) => Number(record.studentId));
      if (new Set(studentIds).size !== studentIds.length) {
        throw new Error('Each student can appear only once in an attendance submission');
      }
      return true;
    })
  ],
  validate,
  asyncHandler(async (req, res) => {
    const attendanceDate = req.body.date.toISOString().slice(0, 10);
    const subjectId = Number(req.body.subjectId);
    const records = req.body.records.map((record) => ({
      studentId: Number(record.studentId),
      status: record.status
    }));
    const studentIds = records.map((record) => record.studentId);

    if (!(await teacherRepository.subjectExists(subjectId))) {
      throw new HttpError(400, 'Subject does not exist');
    }

    const knownStudentCount = await teacherRepository.countStudentsByIds(studentIds);
    if (knownStudentCount !== studentIds.length) {
      throw new HttpError(400, 'One or more students do not exist');
    }

    await teacherRepository.upsertAttendance({
      subjectId,
      attendanceDate,
      markedBy: req.user.userId,
      records
    });

    res.status(201).json({ message: 'Attendance saved successfully' });
  })
);

router.get(
  '/attendance',
  [
    query('subjectId').isInt({ min: 1 }).withMessage('subjectId is required'),
    query('date').optional().isISO8601().withMessage('date must be valid')
  ],
  validate,
  asyncHandler(async (req, res) => {
    res.json({
      attendance: await teacherRepository.getAttendance({
        subjectId: Number(req.query.subjectId),
        attendanceDate: req.query.date
      })
    });
  })
);

module.exports = router;
