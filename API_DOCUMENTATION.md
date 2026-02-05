# API Documentation

## Base URL

**Using Docker Compose:**
```
http://localhost:3000
```

**Running directly (go run):**
```
http://localhost:3000
```

**Note:** See `PORTS.md` for port configuration details.

## Authentication Endpoints

### 1. Register User

Register a new user account.

**Endpoint:** `POST /api/auth/register`

**Request Body:**
```json
{
  "email": "user@example.com",
  "phone": "+1234567890",
  "password": "SecurePass123",
  "full_name": "John Doe"
}
```

**Success Response (201):**
```json
{
  "message": "Registration successful. Please verify your phone number with the OTP sent to you."
}
```

**Error Responses:**
- `400 Bad Request` - Invalid input data
- `409 Conflict` - User already exists

**Example cURL:**
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "phone": "+1234567890",
    "password": "SecurePass123",
    "full_name": "John Doe"
  }'
```

---

### 2. Login

Login with email/phone and password.

**Endpoint:** `POST /api/auth/login`

**Request Body:**
```json
{
  "email_or_phone": "user@example.com",
  "password": "SecurePass123"
}
```

**Success Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid-here",
    "email": "user@example.com",
    "phone": "+1234567890",
    "full_name": "John Doe",
    "profile_photo_url": null,
    "is_verified": true,
    "is_dealer": false
  }
}
```

**Error Responses:**
- `400 Bad Request` - Invalid input
- `401 Unauthorized` - Invalid credentials
- `403 Forbidden` - User not verified

**Example cURL:**
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email_or_phone": "user@example.com",
    "password": "SecurePass123"
  }'
```

---

### 3. Send OTP

Send a verification OTP to a phone number.

**Endpoint:** `POST /api/auth/send-otp`

**Request Body:**
```json
{
  "phone": "+1234567890"
}
```

**Success Response (200):**
```json
{
  "message": "OTP sent successfully"
}
```

**Error Responses:**
- `400 Bad Request` - Invalid phone format
- `429 Too Many Requests` - Rate limit exceeded (max 3 per hour)

**Example cURL:**
```bash
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1234567890"
  }'
```

---

### 4. Verify OTP

Verify the OTP code sent to the phone number.

**Endpoint:** `POST /api/auth/verify-otp`

**Request Body:**
```json
{
  "phone": "+1234567890",
  "code": "123456"
}
```

**Success Response (200):**
```json
{
  "message": "Phone number verified successfully"
}
```

**Error Responses:**
- `400 Bad Request` - Invalid OTP or expired
- `429 Too Many Requests` - Too many verification attempts

**Example cURL:**
```bash
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1234567890",
    "code": "123456"
  }'
```

---

### 5. Refresh Token

Refresh an access token using a refresh token.

**Endpoint:** `POST /api/auth/refresh`

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Success Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses:**
- `400 Bad Request` - Invalid refresh token
- `401 Unauthorized` - Token expired or invalid

**Example cURL:**
```bash
curl -X POST http://localhost:3000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

---

### 6. Logout

Logout the current user (invalidates session).

**Endpoint:** `POST /api/auth/logout`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid or missing token

**Example cURL:**
```bash
curl -X POST http://localhost:3000/api/auth/logout \
  -H "Authorization: Bearer <access_token>"
```

---

### 7. Get Current User

Get the current authenticated user's information.

**Endpoint:** `GET /api/auth/me`

**Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "id": "uuid-here",
  "email": "user@example.com",
  "phone": "+1234567890",
  "full_name": "John Doe",
  "profile_photo_url": null,
  "is_verified": true,
  "is_dealer": false
}
```

**Error Responses:**
- `401 Unauthorized` - Invalid or missing token

**Example cURL:**
```bash
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer <access_token>"
```

---

### 8. Health Check

Check if the API and database are healthy.

**Endpoint:** `GET /health`

**Success Response (200):**
```json
{
  "status": "healthy"
}
```

**Error Response (503):**
```json
{
  "status": "unhealthy",
  "error": "connection error message"
}
```

**Example cURL:**
```bash
curl -X GET http://localhost:3000/health
```

---

## Authentication

Most endpoints require authentication via JWT Bearer token in the Authorization header:

```
Authorization: Bearer <access_token>
```

Access tokens expire after 15 minutes. Use the refresh token endpoint to get a new access token.

Refresh tokens expire after 30 days.

---

## Rate Limiting

- General API: 5 requests per minute per IP address
- OTP sending: 3 requests per hour per phone number
- OTP verification: 3 attempts per OTP code

Rate limit exceeded responses return `429 Too Many Requests`.

---

## Error Response Format

All error responses follow this format:

```json
{
  "error": "Error Type",
  "message": "Detailed error message"
}
```

