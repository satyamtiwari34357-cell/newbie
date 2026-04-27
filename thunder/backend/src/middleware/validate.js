const { validationResult } = require("express-validator");

function validate(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const errorMsg = errors.array().map(err => `${err.path}: ${err.msg}`).join(", ");
    return res.status(400).json({ success: false, message: errorMsg, errors: errors.array() });
  }
  next();
}

module.exports = validate;
