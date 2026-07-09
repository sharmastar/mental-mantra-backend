// backend/src/middleware/errorHandler.js
const { logger } = require('../utils/logger');

function errorHandler(err, req, res, next) {
  logger.error({
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
  });

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ success: false, message: 'Invalid token', code: 'INVALID_TOKEN' });
  }
  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ success: false, message: 'Token expired', code: 'TOKEN_EXPIRED' });
  }

  // Prisma errors
  if (err.code === 'P2002') {
    const field = err.meta?.target?.[0] || 'field';
    return res.status(409).json({ success: false, message: `${field} already exists`, code: 'DUPLICATE_ENTRY' });
  }
  if (err.code === 'P2025') {
    return res.status(404).json({ success: false, message: 'Record not found', code: 'NOT_FOUND' });
  }

  // Validation errors
  if (err.type === 'validation') {
    return res.status(422).json({ success: false, message: err.message, errors: err.errors, code: 'VALIDATION_ERROR' });
  }

  // CORS
  if (err.message?.startsWith('CORS blocked')) {
    return res.status(403).json({ success: false, message: 'CORS policy blocked this request', code: 'CORS_ERROR' });
  }

  // App errors
  if (err.statusCode) {
    return res.status(err.statusCode).json({ success: false, message: err.message, code: err.code });
  }

  // Default 500
  res.status(500).json({
    success: false,
    message: err.message || 'Internal server error',
    code: 'INTERNAL_ERROR',
    stack: err.stack,
  });
}

// App error factory
class AppError extends Error {
  constructor(message, statusCode = 500, code = 'APP_ERROR') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

class NotFoundError extends AppError {
  constructor(resource = 'Resource') {
    super(`${resource} not found`, 404, 'NOT_FOUND');
  }
}

class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED');
  }
}

class ForbiddenError extends AppError {
  constructor(message = 'Access denied') {
    super(message, 403, 'FORBIDDEN');
  }
}

class ValidationError extends AppError {
  constructor(message, errors = []) {
    super(message, 422, 'VALIDATION_ERROR');
    this.type = 'validation';
    this.errors = errors;
  }
}

module.exports = errorHandler;
module.exports.AppError = AppError;
module.exports.NotFoundError = NotFoundError;
module.exports.UnauthorizedError = UnauthorizedError;
module.exports.ForbiddenError = ForbiddenError;
module.exports.ValidationError = ValidationError;
