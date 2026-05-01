const express = require('express');
const { query } = require('express-validator');
const catalogRepository = require('../repositories/catalogRepository');
const { authenticate } = require('../middleware/auth');
const asyncHandler = require('../utils/asyncHandler');
const validate = require('../middleware/validate');

const router = express.Router();

router.use(authenticate);

router.get(
  '/departments',
  asyncHandler(async (_req, res) => {
    res.json({ departments: await catalogRepository.listDepartments() });
  })
);

router.get(
  '/semesters',
  asyncHandler(async (_req, res) => {
    res.json({ semesters: await catalogRepository.listSemesters() });
  })
);

router.get(
  '/subjects',
  [
    query('departmentId').optional().isInt({ min: 1 }).withMessage('departmentId must be valid'),
    query('semesterId').optional().isInt({ min: 1 }).withMessage('semesterId must be valid')
  ],
  validate,
  asyncHandler(async (req, res) => {
    res.json({
      subjects: await catalogRepository.listSubjects({
        departmentId: req.query.departmentId ? Number(req.query.departmentId) : undefined,
        semesterId: req.query.semesterId ? Number(req.query.semesterId) : undefined
      })
    });
  })
);

module.exports = router;
