import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:4000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Handle response errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('authToken');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// Auth APIs
export const authAPI = {
  login: (username, password) =>
    api.post('/login', { username, password }),
  logout: () => {
    localStorage.removeItem('authToken');
  },
  getCurrentUser: () =>
    api.get('/me'),
};

// Survey APIs
export const surveyAPI = {
  submitSurvey: (surveyData) =>
    api.post('/surveys', surveyData),
  getSurveys: (surveyorId = null) =>
    api.get('/surveys', { params: { surveyor_id: surveyorId } }),
  getSurveyById: (id) =>
    api.get(`/surveys/${id}`),
  updateSurvey: (id, data) =>
    api.put(`/surveys/${id}`, data),
};

// Village APIs
export const villageAPI = {
  getVillages: () =>
    api.get('/villages'),
};

// Admin APIs
export const adminAPI = {
  getDashboardStats: () =>
    api.get('/admin/dashboard/stats'),
  getSurveyAnalytics: () =>
    api.get('/admin/analytics'),
  getAllSurveys: (filters = {}) =>
    api.get('/admin/surveys', { params: filters }),
  exportSurveys: (format = 'csv') =>
    api.get(`/admin/surveys/export?format=${format}`),
};

export default api;
