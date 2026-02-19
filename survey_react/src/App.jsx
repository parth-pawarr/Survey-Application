import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useAuthStore } from './store';
import Login from './pages/Login';
import SurveyForm from './pages/SurveyForm';
import SurveyList from './pages/SurveyList';
import AdminDashboard from './pages/AdminDashboard';

// Protected Route Component
function ProtectedRoute({ children, requiredRole = null }) {
  const { isAuthenticated, user } = useAuthStore();

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (requiredRole && user?.role !== requiredRole) {
    return <Navigate to="/login" replace />;
  }

  return children;
}

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />

        <Route
          path="/survey"
          element={
            <ProtectedRoute>
              <SurveyForm />
            </ProtectedRoute>
          }
        />

        <Route
          path="/survey-list"
          element={
            <ProtectedRoute>
              <SurveyList />
            </ProtectedRoute>
          }
        />

        <Route
          path="/admin/dashboard"
          element={
            <ProtectedRoute requiredRole="admin">
              <AdminDashboard />
            </ProtectedRoute>
          }
        />

        <Route path="/" element={<Navigate to="/login" replace />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </Router>
  );
}
