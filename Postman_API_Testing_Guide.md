# Postman API Testing Guide - Rural Survey Backend

## 🚀 Base Configuration
- **Base URL**: `http://localhost:4000`
- **Content-Type**: `application/json`
- **Authentication**: Bearer Token (JWT)

---

## 🔐 Authentication Flow

### 1. Login (Get Token)
**Request:**
- **Method**: POST
- **URL**: `http://localhost:4000/api/login`
- **Headers**: 
  ```
  Content-Type: application/json
  ```
- **Body** (raw JSON):
  ```json
  {
    "username": "admin",
    "password": "admin123"
  }
  ```

**Response (200 OK):**
```json
{
  "user": {
    "id": "6996bd2430620d86bcd34ec3",
    "username": "admin",
    "email": "admin@survey.com",
    "full_name": "Administrator",
    "role": "admin",
    "is_active": true
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJKb2tlbiIsImV4cCI6MTc3MTU3MzcwNSwiaWF0IjoxNzcxNDg3MzA1LCJpc3MiOiJKb2tlbiIsImp0aSI6IjMyYXBja2J2aGRiNDB0Mmo4bzAwMDgyMSIsIm5iZiI6MTc3MTQ3MzcwNSwicm9sZSI6ImFkbWluIiwidXNlcl9pZCI6IjY5OTZiZDI0MzA2MjBkODZiY2QzNGVjMyIsInVzZXJuYW1lIjoiYWRtaW4ifQ.NZtV-Vdro0Bf74vzMXbX5osj95LudcHfaFSmsekSLsk"
}
```

**Test Users:**
```json
// Admin
{
  "username": "admin",
  "password": "admin123"
}

// Surveyor 1
{
  "username": "surveyor1", 
  "password": "survey123"
}

// Surveyor 2
{
  "username": "surveyor2",
  "password": "survey123"
}
```

---

## 📋 Authenticated Routes (Add Authorization Header)

### How to Add Authorization Header in Postman:
1. Go to **Authorization** tab
2. Select **Type**: `Bearer Token`
3. **Token**: Paste the JWT token from login response
4. **Header will be**: `Authorization: Bearer <your-jwt-token>`

---

## 👤 User Routes

### Get Current User
**Request:**
- **Method**: GET
- **URL**: `http://localhost:4000/api/me`
- **Headers**:
  ```
  Authorization: Bearer <your-jwt-token>
  Content-Type: application/json
  ```

**Response (200 OK):**
```json
{
  "id": "6996bd2430620d86bcd34ec3",
  "username": "admin",
  "email": "admin@survey.com", 
  "full_name": "Administrator",
  "role": "admin",
  "is_active": true
}
```

---

## 📊 Survey Routes

### Get All Surveys
**Request:**
- **Method**: GET
- **URL**: `http://localhost:4000/api/surveys`
- **Headers**:
  ```
  Authorization: Bearer <your-jwt-token>
  Content-Type: application/json
  ```
- **Query Params** (optional):
  - `surveyor_id`: Filter by specific surveyor

**Response (200 OK):**
```json
[
  {
    "_id": "6996bd2430620d86bcd34ec4",
    "surveyor_id": "6996bd2430620d86bcd34ec3",
    "village_id": "69961c8530620d6534a26618",
    "status": "completed",
    "phase1": { /* household info */ },
    "phase2": { /* family members */ },
    "phase3": { /* education details */ },
    "phase4": { /* employment details */ },
    "created_at": "2026-02-19T07:34:58.723Z",
    "updated_at": "2026-02-19T07:34:58.723Z"
  }
]
```

### Create New Survey
**Request:**
- **Method**: POST
- **URL**: `http://localhost:4000/api/surveys`
- **Headers**:
  ```
  Authorization: Bearer <your-jwt-token>
  Content-Type: application/json
  ```
- **Body**:
```json
{
  "village_id": "69961c8530620d6534a26618",
  "phase1": {
    "household_number": "HH001",
    "respondent_name": "John Doe",
    "respondent_age": 35,
    "respondent_gender": "male",
    "respondent_education": "graduate",
    "respondent_occupation": "agriculture"
  },
  "phase2": {
    "family_members": [
      {
        "name": "Jane Doe",
        "age": 30,
        "gender": "female",
        "relationship": "spouse",
        "education": "graduate",
        "occupation": "teaching"
      }
    ]
  },
  "phase3": {
    "children": [
      {
        "name": "Child 1",
        "age": 8,
        "gender": "male",
        "education": "primary",
        "school_attending": true,
        "school_type": "government"
      }
    ]
  },
  "phase4": {
    "employment": {
      "primary_occupation": "agriculture",
      "secondary_occupation": "labor",
      "monthly_income": 15000,
      "income_source": "farming"
    },
    "unemployed_members": [
      {
        "name": "Member 1",
        "age": 22,
        "gender": "male",
        "education": "graduate",
        "unemployment_duration": 6,
        "job_searching": true,
        "skills": ["agriculture", "driving"]
      }
    ]
  }
}
```

### Get Survey by ID
**Request:**
- **Method**: GET
- **URL**: `http://localhost:4000/api/surveys/{survey_id}`
- **Headers**:
  ```
  Authorization: Bearer <your-jwt-token>
  Content-Type: application/json
  ```

### Update Survey
**Request:**
- **Method**: PUT
- **URL**: `http://localhost:4000/api/surveys/{survey_id}`
- **Headers**:
  ```
  Authorization: Bearer <your-jwt-token>
  Content-Type: application/json
  ```
- **Body**: Same structure as create, but only include fields to update

---

## 🏘️ Village Routes

### Get All Villages
**Request:**
- **Method**: GET
- **URL**: `http://localhost:4000/api/villages`
- **Headers**:
  ```
  Authorization: Bearer <your-jwt-token>
  Content-Type: application/json
  ```

**Response (200 OK):**
```json
{
  "success": true,
  "villages": [
    {
      "id": "69961c8530620d6534a26618",
      "name": "Rampur",
      "district": "Bareilly",
      "state": "Uttar Pradesh",
      "createdAt": "2026-02-19T07:34:58.723Z"
    },
    {
      "id": "69961c8530620d6534a26619", 
      "name": "Shivpur",
      "district": "Varanasi",
      "state": "Uttar Pradesh",
      "createdAt": "2026-02-19T07:34:58.723Z"
    },
    {
      "id": "69961c8530620d6534a2661a",
      "name": "Gopalpur", 
      "district": "Lucknow",
      "state": "Uttar Pradesh",
      "createdAt": "2026-02-19T07:34:58.723Z"
    },
    {
      "id": "69961c8530620d6534a2661b",
      "name": "Madhavpur",
      "district": "Kanpur Nagar", 
      "state": "Uttar Pradesh",
      "createdAt": "2026-02-19T07:34:58.723Z"
    },
    {
      "id": "69961c8530620d6534a2661c",
      "name": "Krishnapur",
      "district": "Allahabad",
      "state": "Uttar Pradesh",
      "createdAt": "2026-02-19T07:34:58.723Z"
    }
  ]
}
```

---

## 👑 Admin Routes (Admin Role Required)

### Dashboard Statistics
**Request:**
- **Method**: GET
- **URL**: `http://localhost:4000/api/admin/dashboard/stats`
- **Headers**:
  ```
  Authorization: Bearer <admin-jwt-token>
  Content-Type: application/json
  ```

**Response (200 OK):**
```json
{
  "total_surveys": 15,
  "total_villages": 5,
  "total_surveyors": 2,
  "recent_surveys": 3,
  "surveys_by_status": {
    "completed": 10,
    "in_progress": 3,
    "pending": 2
  }
}
```

### Survey Analytics
**Request:**
- **Method**: GET
- **URL**: `http://localhost:4000/api/admin/analytics`
- **Headers**:
  ```
  Authorization: Bearer <admin-jwt-token>
  Content-Type: application/json
  ```

**Response (200 OK):**
```json
{
  "health_analytics": {
    "education_distribution": {
      "no_education": 20,
      "primary": 35,
      "secondary": 25,
      "higher_secondary": 15,
      "graduate": 5
    },
    "occupation_distribution": {
      "agriculture": 40,
      "labor": 25,
      "business": 15,
      "teaching": 10,
      "others": 10
    }
  },
  "employment_analytics": {
    "income_ranges": {
      "0_5000": 30,
      "5001_10000": 25,
      "10001_20000": 15,
      "above_20000": 5
    },
    "unemployment_rate": 15.5
  }
}
```

### Get All Surveys (Admin)
**Request:**
- **Method**: GET
- **URL**: `http://localhost:4000/api/admin/surveys`
- **Headers**:
  ```
  Authorization: Bearer <admin-jwt-token>
  Content-Type: application/json
  ```
- **Query Params** (optional):
  - `village`: Filter by village ID
  - `surveyor`: Filter by surveyor ID
  - `date_range`: Filter by date range (e.g., "2024-01-01,2024-12-31")

### Export Surveys
**Request:**
- **Method**: GET
- **URL**: `http://localhost:4000/api/admin/surveys/export`
- **Headers**:
  ```
  Authorization: Bearer <admin-jwt-token>
  Content-Type: application/json
  ```
- **Query Params**:
  - `format`: `csv` (default) or `json`

**Response**: CSV file download or JSON data

---

## 🔧 Error Responses

### 401 Unauthorized
```json
{
  "errors": {
    "detail": "Unauthorized"
  }
}
```

### 404 Not Found
```json
{
  "errors": {
    "detail": "Not Found"
  }
}
```

### 422 Validation Error
```json
{
  "errors": {
    "field_name": "error message",
    "another_field": "another error message"
  }
}
```

---

## 📝 Testing Workflow

### Step-by-Step Testing:

1. **Start Backend**: Ensure `mix phx.server` is running
2. **Login First**: Get JWT token using `/api/login`
3. **Copy Token**: Copy the `token` value from login response
4. **Set Auth Header**: Add `Authorization: Bearer <token>` to all subsequent requests
5. **Test Routes**: Follow the route examples above
6. **Check Responses**: Verify status codes and JSON structure

### Pro Tips:
- **Environment Variables**: Use different environments for dev/staging/prod
- **Test Collections**: Save requests as Postman collection
- **Token Refresh**: Tokens expire after 24 hours
- **Role Testing**: Test admin vs surveyor permissions
- **Error Handling**: Check 401 responses for expired tokens

---

## 🚨 Common Issues & Solutions

### Port Already in Use
```bash
# Find process using port 4000
netstat -ano | findstr :4000

# Kill process
taskkill /PID <PID> /F
```

### CORS Issues
- Ensure backend has CORS configured (already done)
- Check Origin header in requests
- Verify frontend URL matches CORS origins

### Token Issues
- Ensure token is copied correctly (no extra spaces)
- Check token hasn't expired (24-hour validity)
- Verify Authorization header format: `Bearer <token>`

### MongoDB Connection
- Check MongoDB Atlas connection string in `config/config.exs`
- Verify network connectivity
- Ensure database exists in Atlas

---

## 📱 Mobile Testing (Postman App)

1. **Download Postman** from app store
2. **Import Collection**: Use the provided examples
3. **Sync**: Collection syncs with desktop
4. **Test**: Same workflow as desktop

---

**🎉 Your backend is fully configured and ready for comprehensive API testing!**
