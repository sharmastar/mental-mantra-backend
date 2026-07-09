// backend/src/utils/logger.js
const winston = require('winston');
const fs = require('fs');
const path = require('path');

const logsDir = path.resolve('logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

const logger = winston.createLogger({
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    process.env.NODE_ENV === 'production'
      ? winston.format.json()
      : winston.format.prettyPrint(),
  ),
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple(),
      ),
    }),
    ...(process.env.NODE_ENV === 'production'
      ? [new winston.transports.File({ filename: path.join(logsDir, 'error.log'), level: 'error' }),
         new winston.transports.File({ filename: path.join(logsDir, 'combined.log') })]
      : []),
  ],
});

module.exports = { logger };
