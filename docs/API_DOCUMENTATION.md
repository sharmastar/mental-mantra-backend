# Mental Mantra API Documentation

## Overview

The Mental Mantra platform communicates with a Node.js Express backend and Cloud Firestore services for AI processing and data persistence.

---

## REST Endpoints Summary

### 1. Authentication (`/api/auth`)
- `POST /api/auth/google`: Google Sign-In verification & JWT token issuing.
- `POST /api/auth/refresh`: Refresh expired access tokens.

### 2. AI & Wellness (`/api/ai`)
- `POST /api/ai/coach`: Chat with Nova AI Coach using Genkit inference.
- `POST /api/ai/analyze-journal`: Execute sentiment and theme extraction on text entries.

### 3. Wellness Engine (`/api/wellness`)
- `GET /api/wellness/score`: Retrieve computed wellness metrics and recommendations.
- `POST /api/wellness/checkin`: Log daily check-in metrics (sleep, water, mood).

---

## Security & Headers

All authenticated API requests must include:
```http
Authorization: Bearer <access_token>
Content-Type: application/json
```
