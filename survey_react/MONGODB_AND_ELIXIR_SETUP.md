# MongoDB Schema & Elixir Integration Guide

This document outlines the MongoDB schemas required for the Survey App and how to integrate it with the Elixir/Phoenix backend.

## Collections Overview

### 1. Users Collection

Stores surveyor and admin credentials.

```javascript
// users (or accounts)
{
  _id: ObjectId,
  username: String,          // unique, for login
  password: String,          // bcrypt hashed
  role: String,             // "admin" or "surveyor"
  email: String,            // unique
  full_name: String,
  is_active: Boolean,       // default: true
  created_at: DateTime,
  updated_at: DateTime
}

// Indexes
db.users.createIndex({ username: 1 }, { unique: true })
db.users.createIndex({ email: 1 }, { unique: true })
```

### 2. Villages Collection

List of all villages where surveys are conducted.

```javascript
// villages
{
  _id: ObjectId,
  name: String,             // "Village A", "Village B"
  district: String,
  state: String,
  code: String,             // optional: unique identifier
  population: Number,       // optional
  created_at: DateTime,
  updated_at: DateTime
}

// Indexes
db.villages.createIndex({ name: 1 })
db.villages.createIndex({ district: 1, state: 1 })
```

### 3. Surveys Collection

Main survey response data from surveyors.

```javascript
// surveys
{
  _id: ObjectId,
  surveyor_id: ObjectId,    // ref: users._id
  village_id: ObjectId,     // ref: villages._id
  
  // PHASE 1: Household Basic Information
  phase1: {
    representative_full_name: String,
    mobile_number: String,  // 10 digits
    age: Number,
    gender: String,         // "Male", "Female", "Other"
    total_family_members: Number,
    ayushman_bharat_card_status: String,  // "All Members Have", "Some Members Have", "None Have"
    ayushman_bharat_card_count: Number    // if "Some Members Have"
  },
  
  // PHASE 2: Healthcare Section
  phase2: {
    has_health_issues: String,            // "Yes", "No"
    affected_members: [
      {
        patient_name: String,
        age: Number,
        gender: String,                   // "Male", "Female", "Other"
        health_issue_type: String,        // Selected from predefined list
        other_health_issue: String,       // if type is "Other"
        has_additional_morbidity: String  // "Yes", "No"
      }
    ]
  },
  
  // PHASE 3: Education Section
  phase3: {
    has_school_children: String,          // "Yes", "No"
    children: [
      {
        child_name: String,
        age: Number,
        gender: String,
        education_level: String,          // Selected from predefined list
        has_facing_issues: String,        // "Yes", "No"
        educational_issues: [String],     // Multiple selections
        other_educational_issue: String,  // if "Other" selected
        aware_of_government_schemes: String  // "Yes", "No", "Heard but don't know details"
      }
    ]
  },
  
  // PHASE 4: Employment Section
  phase4: {
    has_employed_members: String,         // "Yes", "No"
    employed_members: [
      {
        name: String,
        age: Number,
        gender: String,
        employment_type: String,          // Selected from predefined list
        other_employment_type: String     // if type is "Other"
      }
    ],
    unemployed_members: [
      {
        name: String,
        age: Number,
        gender: String,
        education_level: String,
        skills: [String],                 // Multiple selections from traditional & other skills
        other_skill: String,              // if "Other" selected
        unemployment_reason: String,      // Selected from predefined list
        other_unemployment_reason: String // if "Other" selected
      }
    ]
  },
  
  submitted_at: DateTime,
  status: String,                        // "submitted", "processing", "completed"
  created_at: DateTime,
  updated_at: DateTime
}

// Indexes
db.surveys.createIndex({ surveyor_id: 1 })
db.surveys.createIndex({ village_id: 1 })
db.surveys.createIndex({ submitted_at: -1 })
db.surveys.createIndex({ surveyor_id: 1, submitted_at: -1 })
```

## Elixir/Phoenix Schema Models

Here's how to define these schemas in Elixir:

### User Model

```elixir
defmodule YourApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :role, :string, default: "surveyor"  # "admin" or "surveyor"
    field :email, :string
    field :full_name, :string
    field :is_active, :boolean, default: true

    has_many :surveys, YourApp.Surveys.Survey, foreign_key: :surveyor_id

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :password, :full_name, :role, :is_active])
    |> validate_required([:username, :email, :password, :role])
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
      _ ->
        changeset
    end
  end
end
```

### Village Model

```elixir
defmodule YourApp.Village do
  use Ecto.Schema
  import Ecto.Changeset

  schema "villages" do
    field :name, :string
    field :district, :string
    field :state, :string
    field :code, :string
    field :population, :integer

    has_many :surveys, YourApp.Surveys.Survey

    timestamps()
  end

  def changeset(village, attrs) do
    village
    |> cast(attrs, [:name, :district, :state, :code, :population])
    |> validate_required([:name, :district, :state])
    |> unique_constraint(:name)
  end
end
```

### Survey Model

```elixir
defmodule YourApp.Surveys.Survey do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "surveys" do
    field :phase1, :map
    field :phase2, :map
    field :phase3, :map
    field :phase4, :map
    field :status, :string, default: "submitted"
    field :submitted_at, :utc_datetime_usec

    belongs_to :surveyor, YourApp.Accounts.User
    belongs_to :village, YourApp.Village

    timestamps()
  end

  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:phase1, :phase2, :phase3, :phase4, :surveyor_id, :village_id, :submitted_at, :status])
    |> validate_required([:phase1, :surveyor_id, :village_id])
  end
end
```

## API Response Formats

### Login Endpoint
**POST /api/auth/login**

Request:
```json
{
  "username": "surveyor1",
  "password": "password123"
}
```

Response (200):
```json
{
  "data": {
    "token": "eyJhbGc...",
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "username": "surveyor1",
      "role": "surveyor",
      "email": "surveyor1@example.com"
    }
  }
}
```

### Submit Survey Endpoint
**POST /api/surveys**

Request Headers:
```
Authorization: Bearer eyJhbGc...
Content-Type: application/json
```

Request Body: [See MongoDB Surveys Collection above]

Response (201):
```json
{
  "data": {
    "id": "507f1f77bcf86cd799439012",
    "surveyor_id": "507f1f77bcf86cd799439011",
    "village_id": "507f1f77bcf86cd799439010",
    "status": "submitted",
    "submitted_at": "2026-02-18T10:30:00Z"
  }
}
```

### Get Surveys Endpoint
**GET /api/surveys**

Query Parameters:
- `surveyor_id` (optional): Filter by surveyor
- `village_id` (optional): Filter by village
- `page` (default: 1): Pagination
- `limit` (default: 20): Items per page

Response (200):
```json
{
  "data": [
    {
      "id": "507f1f77bcf86cd799439012",
      "phase1": { ... },
      "phase2": { ... },
      "phase3": { ... },
      "phase4": { ... },
      "village": {
        "id": "507f1f77bcf86cd799439010",
        "name": "Village A"
      },
      "submitted_at": "2026-02-18T10:30:00Z",
      "status": "submitted"
    }
  ],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```

### Admin Dashboard Stats
**GET /api/admin/dashboard/stats**

Response (200):
```json
{
  "data": {
    "total_surveys": 250,
    "total_surveyors": 15,
    "villages_covered": 8,
    "avg_survey_time": 45,
    "surveys_today": 12,
    "completion_rate": 92.5
  }
}
```

### Survey Analytics
**GET /api/admin/analytics**

Response (200):
```json
{
  "data": {
    "health_issues_distribution": {
      "Diabetes": 45,
      "Hypertension": 38,
      "Heart Disease": 22,
      "Asthma": 18
    },
    "employment_distribution": {
      "Farming": 120,
      "Daily wage labor": 85,
      "Government job": 25,
      "Self-employed": 15
    },
    "education_distribution": {
      "Primary": 45,
      "Secondary": 65,
      "Higher Secondary": 40,
      "College": 25
    },
    "gender_distribution": {
      "Male": 125,
      "Female": 120,
      "Other": 5
    }
  }
}
```

## Implementation Checklist for Backend

- [ ] Create User model with authentication
- [ ] Create Village model with seed data
- [ ] Create Survey model with nested document support
- [ ] Implement JWT token generation for login
- [ ] Create survey submission endpoint with validation
- [ ] Create survey retrieval endpoints
- [ ] Implement admin analytics endpoints
- [ ] Setup CORS for React frontend
- [ ] Create database indexes
- [ ] Setup error handling and validation
- [ ] Create export functionality (CSV/Excel)
- [ ] Implement survey filtering and search
- [ ] Setup logging and monitoring
- [ ] Create database migration scripts

## Database Setup

### MongoDB Atlas (Cloud)
1. Create cluster
2. Create database: `survey_app`
3. Create collections: users, villages, surveys
4. Setup IP whitelist for Elixir server

### Local MongoDB
```bash
# Create database and collections
mongo survey_app

db.createCollection("users")
db.createCollection("villages")
db.createCollection("surveys")

# Create indexes
db.users.createIndex({ username: 1 }, { unique: true })
db.users.createIndex({ email: 1 }, { unique: true })
db.villages.createIndex({ name: 1 })
db.surveys.createIndex({ surveyor_id: 1 })
db.surveys.createIndex({ village_id: 1 })
db.surveys.createIndex({ submitted_at: -1 })
```

## Security Recommendations

1. **Authentication**: Use JWT with expiry
2. **Password**: Hash using bcrypt with salt
3. **HTTPS**: Enable in production
4. **CORS**: Whitelist React frontend URL
5. **Input Validation**: Validate all inputs on backend
6. **Rate Limiting**: Implement on API endpoints
7. **Data Encryption**: Encrypt sensitive fields
8. **Audit Logs**: Track all survey submissions

---

**Document Version**: 1.0  
**Last Updated**: February 18, 2026
