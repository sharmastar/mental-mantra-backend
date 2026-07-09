const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');
const { logger } = require('./logger');

if (!admin.apps.length) {
  // Priority 1: GOOGLE_APPLICATION_CREDENTIALS env var pointing to service account JSON
  const saPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  if (saPath && fs.existsSync(saPath)) {
    admin.initializeApp({ credential: admin.credential.applicationDefault() });
    logger.info('Firebase Admin initialized via GOOGLE_APPLICATION_CREDENTIALS');
  } else {
    // Priority 2: Individual env vars
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

    if (projectId && clientEmail && privateKey) {
      admin.initializeApp({
        credential: admin.credential.cert({ projectId, clientEmail, privateKey }),
        projectId,
      });
      logger.info('Firebase Admin initialized via FIREBASE_* env vars');
    } else {
      logger.warn(
        'Firebase Admin not configured. Google Sign-In will fail.\n' +
        '   Set one of:\n' +
        '     - GOOGLE_APPLICATION_CREDENTIALS (path to service account JSON)\n' +
        '     - FIREBASE_PROJECT_ID + FIREBASE_CLIENT_EMAIL + FIREBASE_PRIVATE_KEY\n' +
        '   Get credentials from: Firebase Console > Project Settings > Service Accounts'
      );
    }
  }
}

module.exports = admin;
