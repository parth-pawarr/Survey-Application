# Survey App - Household Survey System

A comprehensive React-based survey application frontend designed for conducting household surveys with multi-phase questionnaires. The app supports admin dashboard with analytics and is fully responsive for mobile devices.

## Features

✅ **Multi-Phase Survey Form** - 4-phase structured survey questionnaire
- Phase 1: Household Basic Information
- Phase 2: Healthcare Section (Repeatable)
- Phase 3: Education Section (Repeatable)
- Phase 4: Employment Section (Repeatable)

✅ **Authentication** - Surveyor login with credentials
✅ **Admin Dashboard** - View analytics and manage surveys
✅ **Responsive Design** - Desktop and mobile optimized
✅ **Real-time Progress Tracking** - Phase-wise navigation
✅ **Data Validation** - Client-side validation for all fields
✅ **Analytics** - Visual charts for health issues and employment

## Tech Stack

- **Frontend Framework**: React 18.2.0
- **Build Tool**: Vite
- **State Management**: Zustand
- **HTTP Client**: Axios
- **Routing**: React Router DOM
- **Styling**: Tailwind CSS
- **UI Components**: Custom responsive components

## Project Structure

```
survey_react/
├── public/
├── src/
│   ├── components/
│   │   └── phases/
│   │       ├── Phase1.jsx       # Household Basic Information
│   │       ├── Phase2.jsx       # Healthcare Section
│   │       ├── Phase3.jsx       # Education Section
│   │       └── Phase4.jsx       # Employment Section
│   ├── pages/
│   │   ├── Login.jsx            # Surveyor Login
│   │   ├── SurveyForm.jsx       # Main Survey Form
│   │   ├── SurveyList.jsx       # Submitted Surveys
│   │   └── AdminDashboard.jsx   # Admin Analytics
│   ├── services/
│   │   └── api.js               # API integration
│   ├── store/
│   │   └── index.js             # Zustand state stores
│   ├── App.jsx                  # Main app component
│   ├── main.jsx                 # React entry point
│   └── index.css                # Global styles
├── index.html                   # HTML entry point
├── vite.config.js               # Vite configuration
├── tailwind.config.js           # Tailwind configuration
├── postcss.config.js            # PostCSS configuration
├── package.json                 # Dependencies
└── README.md                    # This file
```

## Installation

### Prerequisites
- Node.js (v14 or higher)
- npm or yarn package manager

### Setup Steps

1. **Install dependencies**
```bash
npm install
```

2. **Create .env file** from example
```bash
cp .env.example .env
```

3. **Update .env** with your Elixir backend URL
```
VITE_API_URL=http://localhost:4000/api
```

4. **Start development server**
```bash
npm run dev
```

The app will be available at `http://localhost:3000`

## Building for Production

```bash
npm run build
```

Optimized production build will be in the `dist/` directory.

## API Integration (Elixir Backend)

This React app communicates with an Elixir backend using REST APIs. The API endpoints are defined in `src/services/api.js`.

### Expected API Endpoints

#### Authentication
- `POST /api/auth/login` - Login with credentials
- `POST /api/auth/logout` - Logout user

#### Survey Management
- `POST /api/surveys` - Submit survey
- `GET /api/surveys` - Get surveyor's surveys
- `GET /api/surveys/:id` - Get survey details
- `PUT /api/surveys/:id` - Update survey

#### Village Management
- `GET /api/villages` - Get list of all villages

#### Admin APIs
- `GET /api/admin/dashboard/stats` - Get dashboard statistics
- `GET /api/admin/analytics` - Get survey analytics
- `GET /api/admin/surveys` - Get all surveys
- `GET /api/admin/surveys/export?format=csv` - Export surveys

### Request/Response Format

**Login Request**
```json
{
  "username": "surveyor1",
  "password": "password123"
}
```

**Login Response**
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "username": "surveyor1",
    "role": "surveyor"
  }
}
```

**Survey Submission**
```json
{
  "phase1": {
    "representativeFullName": "John Doe",
    "mobileNumber": "9876543210",
    "age": 45,
    "gender": "Male",
    "totalFamilyMembers": 5,
    "ayushmanCardStatus": "All Members Have",
    "ayushmanCardCount": ""
  },
  "phase2": {
    "hasHealthIssues": "Yes",
    "affectedMembers": [
      {
        "patientName": "Jane Doe",
        "age": 42,
        "gender": "Female",
        "healthIssueType": "Diabetes",
        "otherHealthIssue": "",
        "hasAdditionalMorbidity": "No"
      }
    ]
  },
  "phase3": {
    "hasSchoolChildren": "Yes",
    "children": [
      {
        "childName": "Jack Doe",
        "age": 15,
        "gender": "Male",
        "educationLevel": "Secondary",
        "hasFacingIssues": "No",
        "educationalIssues": [],
        "otherEducationalIssue": "",
        "awareOfSchemes": "Yes"
      }
    ]
  },
  "phase4": {
    "hasEmployedMembers": "Yes",
    "employedMembers": [
      {
        "name": "John Doe",
        "age": 45,
        "gender": "Male",
        "employmentType": "Farming",
        "otherEmploymentType": ""
      }
    ],
    "unemployedMembers": []
  },
  "village": "village_id",
  "surveyorId": "surveyor_id",
  "submittedAt": "2026-02-18T10:30:00Z"
}
```

## MongoDB Schema Reference

The survey data is stored in MongoDB. Here's the expected schema:

```javascript
// Surveys Collection
{
  _id: ObjectId,
  phase1: {
    representativeFullName: String,
    mobileNumber: String,
    age: Number,
    gender: String (Male|Female|Other),
    totalFamilyMembers: Number,
    ayushmanCardStatus: String,
    ayushmanCardCount: Number
  },
  phase2: {
    hasHealthIssues: String (Yes|No),
    affectedMembers: [{
      patientName: String,
      age: Number,
      gender: String,
      healthIssueType: String,
      otherHealthIssue: String,
      hasAdditionalMorbidity: String
    }]
  },
  phase3: {
    hasSchoolChildren: String (Yes|No),
    children: [{
      childName: String,
      age: Number,
      gender: String,
      educationLevel: String,
      hasFacingIssues: String,
      educationalIssues: [String],
      otherEducationalIssue: String,
      awareOfSchemes: String
    }]
  },
  phase4: {
    hasEmployedMembers: String (Yes|No),
    employedMembers: [{
      name: String,
      age: Number,
      gender: String,
      employmentType: String,
      otherEmploymentType: String
    }],
    unemployedMembers: [{
      name: String,
      age: Number,
      gender: String,
      educationLevel: String,
      skills: [String],
      otherSkill: String,
      unemploymentReason: String,
      otherUnemploymentReason: String
    }]
  },
  village: ObjectId (ref: Villages),
  surveyorId: ObjectId (ref: Users),
  submittedAt: Date,
  createdAt: Date,
  updatedAt: Date,
  status: String (submitted|processing|completed)
}

// Villages Collection
{
  _id: ObjectId,
  name: String,
  district: String,
  state: String,
  createdAt: Date
}

// Users Collection
{
  _id: ObjectId,
  username: String (unique),
  password: String (hashed),
  role: String (admin|surveyor),
  email: String,
  createdAt: Date,
  updatedAt: Date
}
```

## Usage Guide

### For Surveyors

1. **Login**: Navigate to the login page and enter credentials
2. **Create Survey**: Click "New Survey" to start
3. **Select Village**: Choose the village where survey is being conducted
4. **Fill Phases**: Complete all 4 phases of the questionnaire
5. **Submit**: Review and submit the survey
6. **Track**: View all submitted surveys in "My Surveys" section

### For Admins

1. **Login**: Use admin credentials to access dashboard
2. **View Analytics**: See health issues and employment distribution charts
3. **Manage Surveys**: View all submitted surveys
4. **Search & Filter**: Search by surveyor name or village
5. **Export Data**: Export surveys in CSV format

## Features Breakdown

### Phase 1: Household Basic Information
- Representative name, contact, age, gender
- Family size counting
- Ayushman Bharat card eligibility tracking

### Phase 2: Healthcare Section
- Track family members with health issues
- Record health conditions (12 predefined + custom)
- Monitor additional morbidities

### Phase 3: Education Section
- Track school/college-going children
- Monitor educational challenges
- Awareness about government education schemes

### Phase 4: Employment Section
- Record employed members with job types
- Track unemployed members
- Skill assessment (traditional & modern skills)
- Unemployment reason analysis

### Admin Features
- Real-time survey submission tracking
- Health issue distribution analytics
- Employment pattern analysis
- Village-wise coverage metrics
- CSV export functionality
- Search and filter capabilities

## Responsive Design

The app is fully responsive for:
- **Desktop**: Full feature width, multi-column layouts
- **Tablet**: Optimized for 768px+ screens
- **Mobile**: Touch-friendly interface, single-column layouts

## Environment Variables

Create a `.env` file based on `.env.example`:

```
VITE_API_URL=http://localhost:4000/api
VITE_APP_MODE=development
```

## Troubleshooting

### API Connection Issues
- Ensure Elixir backend is running on the specified port
- Check CORS configuration on backend
- Verify API URLs in `.env` file

### State Management
- The app uses Zustand for state management
- Check browser DevTools for store state
- Clear localStorage if authentication issues occur

### Form Validation
- All required fields are marked with *
- Mobile number must be 10 digits
- Age fields accept 1-150 years

## Browser Support

- Chrome (recommended)
- Firefox
- Safari
- Edge
- Mobile browsers (Chrome Mobile, Safari iOS)

## Performance

- Lazy loading of components
- Optimized bundle size (~150KB gzipped)
- Efficient state updates with Zustand
- Image optimization & caching
- CSS minification

## Security Notes

- Authentication tokens stored in localStorage
- HTTPS recommended for production
- Input validation on client-side
- CORS configured for trusted domains
- Sensitive data should not be stored in localStorage for production

## License

This project is proprietary and confidential.

## Support

For issues or questions, contact the development team.

---

**Version**: 1.0.0  
**Last Updated**: February 18, 2026
