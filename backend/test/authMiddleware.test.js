const test = require('node:test');
const assert = require('node:assert/strict');
const jwt = require('jsonwebtoken');
const env = require('../src/config/env');
const { authenticate, authorize } = require('../src/middleware/auth');

function runMiddleware(middleware, req = {}) {
  return new Promise((resolve) => {
    middleware(req, {}, (error) => resolve({ error, req }));
  });
}

test('authenticate accepts a valid bearer token', async () => {
  const token = jwt.sign({ userId: 1, role: 'teacher' }, env.jwtSecret);
  const { error, req } = await runMiddleware(authenticate, {
    headers: { authorization: `Bearer ${token}` }
  });

  assert.equal(error, undefined);
  assert.equal(req.user.userId, 1);
  assert.equal(req.user.role, 'teacher');
});

test('authenticate rejects a missing token', async () => {
  const { error } = await runMiddleware(authenticate, { headers: {} });

  assert.equal(error.status, 401);
});

test('authorize rejects users outside the required role', async () => {
  const { error } = await runMiddleware(authorize('teacher'), {
    user: { role: 'student' }
  });

  assert.equal(error.status, 403);
});
