# Quick Start Guide

## 🚀 Getting Started with Survey App

### Prerequisites
- Node.js (v14+) and npm installed
- Elixir backend running on `http://localhost:4000`
- MongoDB instance available

### Installation (Already Completed ✅)

Dependencies are already installed via `npm install`. No additional setup required!

### Running the Application

#### Development Mode

```bash
npm run dev
```

The app will start at **http://localhost:3000**

#### Production Build

```bash
npm run build
npm run preview
```

### Configuration

The `.env` file is already configured to point to your Elixir backend:
```
VITE_API_URL=http://localhost:4000/api
```

Modify this if your backend runs on a different port.

### Project Files Created

✅ **Configuration Files**
- `package.json` - Dependencies
- `vite.config.js` - Vite configuration
- `tailwind.config.js` - Tailwind CSS config
- `postcss.config.js` - PostCSS config
- `.env` - Environment variables
- `.eslintrc.json` - ESLint rules
- `.gitignore` - Git ignore rules

✅ **Source Code**
- `src/main.jsx` - React entry point
- `src/App.jsx` - Main app with routing
- `src/index.css` - Global styles
- `src/pages/Login.jsx` - Surveyor login
- `src/pages/SurveyForm.jsx` - Main survey form
- `src/pages/SurveyList.jsx` - Survey list for surveyors
- `src/pages/AdminDashboard.jsx` - Admin analytics dashboard
- `src/components/phases/Phase1.jsx` - Household info form
- `src/components/phases/Phase2.jsx` - Healthcare form
- `src/components/phases/Phase3.jsx` - Education form
- `src/components/phases/Phase4.jsx` - Employment form
- `src/services/api.js` - API integration layer
- `src/store/index.js` - Zustand state management

✅ **Documentation**
- `README.md` - Complete documentation
- `MONGODB_AND_ELIXIR_SETUP.md` - Backend integration guide

### Key Features Implemented

#### Authentication
- User login with username/password
- JWT token management
- Protected routes based on role (admin/surveyor)

#### Surveyor Interface
- 4-phase survey form with navigation
- Village selection
- Repeatable sections (health issues, children, employment)
- Form validation
- Survey submission
- View submitted surveys

#### Admin Dashboard
- Survey statistics and metrics
- Health issues distribution chart
- Employment pattern analytics
- All surveys list with search/filter
- CSV export functionality
- Responsive design

#### Mobile Responsive
- All pages optimized for mobile
- Touch-friendly interface
- Responsive navigation
- Mobile-first design approach

### Login Credentials (Demo)

For testing purposes, use:
```
Username: surveyor1
Password: password123
```

For admin access:
```
Username: admin
Password: admin123
```

(These credentials must be created in your Elixir backend)

### API Endpoints Expected

The React app expects these endpoints from your Elixir backend:

**Authentication**
- `POST /api/auth/login`

**Surveys**
- `POST /api/surveys` - Submit survey
- `GET /api/surveys` - Get surveys

**Villages**
- `GET /api/villages` - Get list of villages

**Admin**
- `GET /api/admin/dashboard/stats` - Dashboard stats
- `GET /api/admin/analytics` - Analytics data
- `GET /api/admin/surveys` - All surveys
- `GET /api/admin/surveys/export` - Export surveys

### Development Workflow

1. **Start Development Server**
   ```bash
   npm run dev
   ```

2. **Make Changes**
   - Edit files in `src/` directory
   - Changes auto-refresh in browser

3. **Build for Production**
   ```bash
   npm run build
   ```

4. **Deploy**
   - Upload `dist/` folder to hosting service

### Troubleshooting

#### API Connection Failed
- Ensure Elixir backend is running on port 4000
- Check `VITE_API_URL` in `.env`
- Verify CORS is enabled on backend

#### Module Not Found Errors
- Run `npm install` again
- Delete `node_modules/` and `package-lock.json`
- Run `npm install` fresh

#### Styling Issues
- Clear browser cache
- Run `npm run build`
- Check Tailwind CSS is properly configured

#### State Management
- App uses Zustand for state
- Check browser DevTools for store state
- Clear localStorage if auth issues occur

### File Structure Explanation

```
src/
├── pages/              # Full page components
│   ├── Login.jsx      # Login page
│   ├── SurveyForm.jsx # Main survey form
│   ├── SurveyList.jsx # Survey list view
│   └── AdminDashboard.jsx # Admin dashboard
├── components/        # Reusable components
│   └── phases/       # Survey phase components
├── services/         # API & external services
├── store/           # Global state (Zustand)
├── App.jsx          # App routing
├── main.jsx         # Entry point
└── index.css        # Global styles
```

### Next Steps

1. ✅ React frontend ready
2. Create Elixir/Phoenix backend
3. Implement MongoDB models
4. Create API endpoints
5. Setup authentication
6. Test integration
7. Deploy to production

### Support

For detailed documentation, see:
- `README.md` - Complete feature documentation
- `MONGODB_AND_ELIXIR_SETUP.md` - Backend schema & integration

---

**You're all set to start building!** 🎉
