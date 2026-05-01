const express = require('express');
const studentRepository = require('../repositories/studentRepository');
const { authenticate, authorize } = require('../middleware/auth');
const asyncHandler = require('../utils/asyncHandler');
const HttpError = require('../utils/httpError');

const router = express.Router();

router.use(authenticate, authorize('student'));

function requireStudentProfile(req) {
  if (!req.user.studentId) {
    throw new HttpError(403, 'Student profile is not linked to this account');
  }
  return req.user.studentId;
}

router.get(
  '/attendance',
  asyncHandler(async (req, res) => {
    res.json({
      attendance: await studentRepository.getAttendance(requireStudentProfile(req))
    });
  })
);

router.get(
  '/attendance/summary',
  asyncHandler(async (req, res) => {
    res.json({
      summary: await studentRepository.getSummary(requireStudentProfile(req))
    });
  })
);

module.exports = router;
