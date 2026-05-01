const { validationResult } = require('express-validator');
const HttpError = require('../utils/httpError');

function validate(req, _res, next) {
  const result = validationResult(req);

  if (result.isEmpty()) {
    return next();
  }

  const message = result
    .array()
    .map((error) => error.msg)
    .join(', ');

  return next(new HttpError(400, message));
}

module.exports = validate;
