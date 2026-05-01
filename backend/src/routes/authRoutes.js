const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body } = require('express-validator');
const env = require('../config/env');
const usersRepository = require('../repositories/usersRepository');
const asyncHandler = require('../utils/asyncHandler');
const HttpError = require('../utils/httpError');
const validate = require('../middleware/validate');

const router = express.Router();

router.post(
  '/login',
  [
    body('email').isEmail().withMessage('Valid email is required'),
    body('password').notEmpty().withMessage('Password is required')
  ],
  validate,
  asyncHandler(async (req, res) => {
    const { email, password } = req.body;
    const user = await usersRepository.findByEmail(email.toLowerCase());

    if (!user) {
      throw new HttpError(401, 'Invalid email or password');
    }

    const passwordMatches = await bcrypt.compare(password, user.password);
    if (!passwordMatches) {
      throw new HttpError(401, 'Invalid email or password');
    }

    let studentProfile = null;
    if (user.role === 'student') {
      studentProfile = await usersRepository.findStudentProfileByUserId(user.user_id);
    }

    const token = jwt.sign(
      {
        userId: user.user_id,
        name: user.name,
        email: user.email,
        role: user.role,
        studentId: studentProfile?.student_id || null
      },
      env.jwtSecret,
      { expiresIn: env.jwtExpiresIn }
    );

    res.json({
      token,
      user: {
        userId: user.user_id,
        name: user.name,
        email: user.email,
        role: user.role,
        student: studentProfile
      }
    });
  })
);

module.exports = router;
