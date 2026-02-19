# File Structure & Component Map

## Complete Directory Tree

```
survey_react/
│
├── 📋 CONFIGURATION & BUILD
├── package.json                    # npm dependencies & scripts
├── package-lock.json               # dependency lock file
├── vite.config.js                  # Vite bundler configuration
├── tailwind.config.js              # Tailwind CSS theme config
├── postcss.config.js               # PostCSS pipeline config
├── .eslintrc.json                  # ESLint code quality rules
│
├── 🔐 ENVIRONMENT
├── .env                            # Current environment variables
├── .env.example                    # Environment template
├── .gitignore                      # Git ignore patterns
│
├── 🌐 PRODUCTION BUILD
├── dist/                           # Production-ready files (after npm run build)
│   ├── index.html                  # Main HTML entry point
│   └── assets/                     # Bundled JS & CSS
│       ├── index-[hash].js        # React app bundle (~76KB gzipped)
│       └── index-[hash].css       # Tailwind CSS (~4KB gzipped)
│
├── 📄 STATIC FILES
├── index.html                      # HTML template
│
├── 📚 DOCUMENTATION (4 files)
├── README.md                       # Complete feature documentation
├── QUICK_START.md                  # Quick start guide
├── DEPLOYMENT_GUIDE.md             # Deployment instructions
├── MONGODB_AND_ELIXIR_SETUP.md     # Backend schema & setup
└── PROJECT_SUMMARY.md              # This summary document
│
└── 📦 SOURCE CODE (src/)
    │
    ├── 🎯 ENTRY POINTS
    ├── main.jsx                    # React DOM mount point
    ├── App.jsx                     # Root component with routing
    └── index.css                   # Global styles + Tailwind
    │
    ├── 📄 PAGES (4 full-page components)
    ├── pages/
    │   ├── Login.jsx               # Surveyor/Admin login
    │   │   └── Features:
    │   │       • Username/password input
    │   │       • JWT token handling
    │   │       • Role-based redirect
    │   │       • Error messages
    │   │
    │   ├── SurveyForm.jsx          # Main 4-phase survey form
    │   │   └── Features:
    │   │       • Phase navigation (1-4)
    │   │       • Progress bar
    │   │       • Village selection
    │   │       • Form submission
    │   │       • Loading states
    │   │
    │   ├── SurveyList.jsx          # Surveyor's survey history
    │   │   └── Features:
    │   │       • View submitted surveys
    │   │       • Survey statistics
    │   │       • Search & filter
    │   │       • New survey button
    │   │
    │   └── AdminDashboard.jsx      # Admin analytics dashboard
    │       └── Features:
    │           • Survey statistics (4 cards)
    │           • Health issues chart
    │           • Employment distribution
    │           • All surveys table
    │           • CSV export
    │           • Search functionality
    │
    ├── 🧩 REUSABLE COMPONENTS (4 phase forms)
    ├── components/
    │   └── phases/
    │       │
    │       ├── Phase1.jsx          # Household Basic Information
    │       │   ├── Representative name (text)
    │       │   ├── Mobile number (10 digits)
    │       │   ├── Age (number)
    │       │   ├── Gender (radio: M/F/Other)
    │       │   ├── Family members (number)
    │       │   └── Ayushman card status (radio + conditional)
    │       │
    │       ├── Phase2.jsx          # Healthcare Section (Repeatable)
    │       │   ├── Has health issues (radio: Yes/No)
    │       │   └── Affected members (repeatable):
    │       │       ├── Patient name
    │       │       ├── Age
    │       │       ├── Gender
    │       │       ├── Health issue (dropdown: 12 options)
    │       │       └── Additional morbidity (radio)
    │       │
    │       ├── Phase3.jsx          # Education Section (Repeatable)
    │       │   ├── Has school children (radio: Yes/No)
    │       │   └── Children (repeatable):
    │       │       ├── Child name
    │       │       ├── Age
    │       │       ├── Gender
    │       │       ├── Education level (dropdown: 8 options)
    │       │       ├── Facing issues (radio: Yes/No)
    │       │       ├── Educational issues (checkbox: 9 options)
    │       │       └── Aware of schemes (radio: 3 options)
    │       │
    │       └── Phase4.jsx          # Employment Section (Repeatable)
    │           ├── Has employed members (radio: Yes/No)
    │           ├── Employed members (repeatable):
    │           │   ├── Name
    │           │   ├── Age
    │           │   ├── Gender
    │           │   └── Employment type (dropdown: 9 options)
    │           │
    │           └── Unemployed members (repeatable):
    │               ├── Name
    │               ├── Age
    │               ├── Gender
    │               ├── Education level (dropdown: 6 options)
    │               ├── Skills (checkbox: 24 options)
    │               └── Unemployment reason (dropdown: 8 options)
    │
    ├── 🔌 SERVICES (API Integration)
    ├── services/
    │   └── api.js                  # Axios HTTP client + endpoints
    │       ├── Configuration
    │       │   • Base URL setup
    │       │   • Request interceptors (token injection)
    │       │   • Response interceptors (error handling)
    │       │
    │       └── API Modules
    │           ├── authAPI
    │           │   ├── login(username, password)
    │           │   └── logout()
    │           │
    │           ├── surveyAPI
    │           │   ├── submitSurvey(data)
    │           │   ├── getSurveys(surveyorId)
    │           │   ├── getSurveyById(id)
    │           │   └── updateSurvey(id, data)
    │           │
    │           ├── villageAPI
    │           │   └── getVillages()
    │           │
    │           └── adminAPI
    │               ├── getDashboardStats()
    │               ├── getSurveyAnalytics()
    │               ├── getAllSurveys(filters)
    │               └── exportSurveys(format)
    │
    └── 🎯 STATE MANAGEMENT (Zustand)
        └── store/
            └── index.js            # Global state stores
                │
                ├── useAuthStore
                │   ├── user
                │   ├── token
                │   ├── isAuthenticated
                │   ├── isLoading
                │   ├── error
                │   ├── setUser()
                │   ├── setToken()
                │   ├── clearAuth()
                │   ├── setLoading()
                │   └── setError()
                │
                ├── useSurveyFormStore
                │   ├── phase1 data
                │   ├── phase2 data
                │   ├── phase3 data
                │   ├── phase4 data
                │   ├── village
                │   ├── currentPhase
                │   ├── updatePhaseX()
                │   ├── addMember()
                │   ├── removeItem()
                │   ├── getFormData()
                │   ├── resetForm()
                │   └── ... (20+ actions)
                │
                └── useAdminStore
                    ├── stats
                    ├── surveys
                    ├── analytics
                    ├── isLoading
                    ├── error
                    ├── setStats()
                    ├── setSurveys()
                    ├── setAnalytics()
                    ├── setLoading()
                    └── setError()

└── 📂 node_modules/
    └── All npm packages (201 packages installed)
```

---

## Component Communication Flow

```
main.jsx
  ↓
App.jsx (Routing & Role-based Access)
  │
  ├─→ Login.jsx
  │   └─→ useAuthStore.setToken()
  │
  ├─→ SurveyForm.jsx
  │   ├─→ Phase1.jsx      ┐
  │   ├─→ Phase2.jsx      ├─→ useSurveyFormStore
  │   ├─→ Phase3.jsx      ├─ Updates form data
  │   ├─→ Phase4.jsx      ┴─ On submit → surveyAPI.submitSurvey()
  │   │
  │   └─→ villageAPI.getVillages()
  │
  ├─→ SurveyList.jsx
  │   └─→ surveyAPI.getSurveys()
  │
  └─→ AdminDashboard.jsx
      ├─→ adminAPI.getDashboardStats()
      ├─→ adminAPI.getSurveyAnalytics()
      └─→ adminAPI.getAllSurveys()
```

---

## Data Flow & State Management

```
USER LOGIN
  │
  └─→ Login.jsx
      └─→ authAPI.login()
          └─→ useAuthStore.setToken()
              └─→ setUser()
                  └─→ Navigate to /survey or /admin/dashboard
                  
SURVEY SUBMISSION
  │
  └─→ SurveyForm.jsx
      ├─→ Phase1.jsx → useSurveyFormStore.updatePhase1()
      ├─→ Phase2.jsx → useSurveyFormStore.addAffectedMember()
      ├─→ Phase3.jsx → useSurveyFormStore.addChild()
      └─→ Phase4.jsx → useSurveyFormStore.addEmployedMember()
          │
          └─→ handleSubmit()
              └─→ surveyAPI.submitSurvey()
                  └─→ Navigation to /survey-list
                  
ADMIN DASHBOARD
  │
  └─→ AdminDashboard.jsx (Component Mount)
      ├─→ adminAPI.getDashboardStats()
      │   └─→ useAdminStore.setStats()
      │       └─→ Render stat cards
      │
      ├─→ adminAPI.getSurveyAnalytics()
      │   └─→ useAdminStore.setAnalytics()
      │       └─→ Render charts
      │
      └─→ adminAPI.getAllSurveys()
          └─→ useAdminStore.setSurveys()
              └─→ Render table
```

---

## File Size Reference

| File | Size | Gzipped | Purpose |
|------|------|---------|---------|
| Vite Build | 243.5 KB | 76.18 KB | JavaScript bundle |
| Tailwind CSS | 19.4 KB | 3.95 KB | Global styles |
| HTML | 0.44 KB | 0.31 KB | Entry point |
| **Total** | **263.3 KB** | **~80 KB** | **Complete app** |

---

## Import Relationships

### Main App Imports
```
App.jsx imports:
  ├── pages/Login.jsx
  ├── pages/SurveyForm.jsx
  ├── pages/SurveyList.jsx
  ├── pages/AdminDashboard.jsx
  └── store/index.js (useAuthStore)
```

### SurveyForm Imports
```
SurveyForm.jsx imports:
  ├── components/phases/Phase1.jsx
  ├── components/phases/Phase2.jsx
  ├── components/phases/Phase3.jsx
  ├── components/phases/Phase4.jsx
  ├── services/api.js (surveyAPI, villageAPI)
  └── store/index.js (useSurveyFormStore, useAuthStore)
```

### AdminDashboard Imports
```
AdminDashboard.jsx imports:
  ├── services/api.js (adminAPI)
  ├── store/index.js (useAuthStore, useAdminStore)
  └── react-router-dom (useNavigate)
```

---

## Development vs Production

| Aspect | Development | Production |
|--------|-------------|------------|
| Start | `npm run dev` | `npm run build` |
| Port | localhost:3000 | Varies (Vercel, Netlify, etc) |
| API URL | localhost:4000 | Production domain |
| Source Maps | Included | Excluded |
| Minification | No | Yes |
| Bundle Size | Larger | ~80KB gzipped |
| Hot Reload | Yes | N/A |

---

## Environment Variables

```
.env (Development)
├── VITE_API_URL=http://localhost:4000/api
└── VITE_APP_MODE=development

.env.production (After Deployment)
├── VITE_API_URL=https://your-domain.com/api
└── VITE_APP_MODE=production
```

---

## Key Directories Purpose

| Directory | Purpose | Files |
|-----------|---------|-------|
| `src/` | Source code | .jsx, .js, .css |
| `src/pages/` | Full-page components | 4 files |
| `src/components/` | Reusable components | Phase forms |
| `src/services/` | External API calls | api.js |
| `src/store/` | Global state | Zustand stores |
| `dist/` | Production build | Static files (deploy this) |
| `node_modules/` | Dependencies | 201 packages |

---

## TypeScript Ready

While currently in JavaScript, the project can be easily converted to TypeScript:

1. Rename files: `.jsx` → `.tsx`, `.js` → `.ts`
2. Add type definitions:
```typescript
// api.ts
interface LoginRequest {
  username: string;
  password: string;
}

interface LoginResponse {
  token: string;
  user: User;
}
```

---

## Testing Structure (Ready for Integration)

```
tests/
├── unit/
│   ├── store.test.js          # Zustand stores
│   └── api.test.js            # API functions
│
├── components/
│   ├── Phase1.test.jsx
│   ├── Phase2.test.jsx
│   ├── Phase3.test.jsx
│   └── Phase4.test.jsx
│
└── e2e/
    ├── login.test.js
    ├── survey-submission.test.js
    └── admin-dashboard.test.js
```

---

**Ready to Deploy!** 🚀

All files are organized and ready for:
- ✅ Development
- ✅ Production build
- ✅ Deployment
- ✅ Team collaboration
- ✅ Future enhancements
