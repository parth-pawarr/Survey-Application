import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore, useAdminStore } from '../store';
import { adminAPI } from '../services/api';
import '../index.css';

export default function AdminDashboard() {
  const navigate = useNavigate();
  const { user, clearAuth } = useAuthStore();
  const { setStats, setAnalytics, setSurveys } = useAdminStore();

  const [stats, setLocalStats] = useState(null);
  const [analytics, setLocalAnalytics] = useState(null);
  const [surveys, setLocalSurveys] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [filter, setFilter] = useState('');

  useEffect(() => {
    if (user?.role !== 'admin') {
      navigate('/login');
    }
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    setLoading(true);
    try {
      const [statsRes, analyticsRes, surveysRes] = await Promise.all([
        adminAPI.getDashboardStats(),
        adminAPI.getSurveyAnalytics(),
        adminAPI.getAllSurveys(),
      ]);

      setLocalStats(statsRes.data);
      setLocalAnalytics(analyticsRes.data);
      setLocalSurveys(surveysRes.data);

      setStats(statsRes.data);
      setAnalytics(analyticsRes.data);
      setSurveys(surveysRes.data);
    } catch (err) {
      setError('Failed to load dashboard data');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    clearAuth();
    navigate('/login');
  };

  const handleExport = async (format) => {
    try {
      const response = await adminAPI.exportSurveys(format);
      // Handle file download
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `surveys.${format}`);
      document.body.appendChild(link);
      link.click();
    } catch (err) {
      setError('Failed to export surveys');
    }
  };

  const filteredSurveys = surveys.filter(
    (survey) =>
      survey.phase1?.representativeFullName
        ?.toLowerCase()
        .includes(filter.toLowerCase()) ||
      survey.village?.name?.toLowerCase().includes(filter.toLowerCase())
  );

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mb-4"></div>
          <p className="text-gray-600">Loading dashboard...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Header */}
      <header className="bg-white shadow-md">
        <div className="container-responsive flex justify-between items-center">
          <div>
            <h1 className="text-2xl md:text-3xl font-bold text-gray-800">
              Admin Dashboard
            </h1>
            <p className="text-gray-600">Manage household surveys</p>
          </div>
          <button
            onClick={handleLogout}
            className="btn-secondary px-6 py-2"
          >
            Logout
          </button>
        </div>
      </header>

      <main className="container-responsive">
        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
            {error}
          </div>
        )}

        {/* Stats Cards */}
        {stats && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 my-8">
            <div className="card border-l-4 border-blue-500">
              <p className="text-gray-600 text-sm">Total Surveys</p>
              <p className="text-3xl font-bold text-blue-600">
                {stats.totalSurveys || 0}
              </p>
            </div>

            <div className="card border-l-4 border-green-500">
              <p className="text-gray-600 text-sm">Total Surveyors</p>
              <p className="text-3xl font-bold text-green-600">
                {stats.totalSurveyors || 0}
              </p>
            </div>

            <div className="card border-l-4 border-purple-500">
              <p className="text-gray-600 text-sm">Villages Covered</p>
              <p className="text-3xl font-bold text-purple-600">
                {stats.villagesCovered || 0}
              </p>
            </div>

            <div className="card border-l-4 border-orange-500">
              <p className="text-gray-600 text-sm">Avg Survey Time</p>
              <p className="text-3xl font-bold text-orange-600">
                {stats.avgSurveyTime || 0} min
              </p>
            </div>
          </div>
        )}

        {/* Analytics Section */}
        {analytics && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
            <div className="card">
              <h3 className="text-xl font-bold mb-4">Health Issues Distribution</h3>
              <div className="space-y-3">
                {Object.entries(analytics.healthIssuesDistribution || {})
                  .slice(0, 5)
                  .map(([issue, count]) => (
                    <div key={issue} className="flex items-center justify-between">
                      <span className="text-gray-700">{issue}</span>
                      <div className="flex items-center gap-2">
                        <div className="w-32 bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-blue-500 h-2 rounded-full"
                            style={{
                              width: `${Math.min(count * 10, 100)}%`,
                            }}
                          ></div>
                        </div>
                        <span className="font-semibold text-gray-800 w-8 text-right">
                          {count}
                        </span>
                      </div>
                    </div>
                  ))}
              </div>
            </div>

            <div className="card">
              <h3 className="text-xl font-bold mb-4">Employment Status</h3>
              <div className="space-y-3">
                {Object.entries(analytics.employmentDistribution || {})
                  .slice(0, 5)
                  .map(([employment, count]) => (
                    <div key={employment} className="flex items-center justify-between">
                      <span className="text-gray-700">{employment}</span>
                      <div className="flex items-center gap-2">
                        <div className="w-32 bg-gray-200 rounded-full h-2">
                          <div
                            className="bg-green-500 h-2 rounded-full"
                            style={{
                              width: `${Math.min(count * 10, 100)}%`,
                            }}
                          ></div>
                        </div>
                        <span className="font-semibold text-gray-800 w-8 text-right">
                          {count}
                        </span>
                      </div>
                    </div>
                  ))}
              </div>
            </div>
          </div>
        )}

        {/* Surveys Table */}
        <div className="card">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between mb-6 gap-4">
            <h3 className="text-xl font-bold">Recent Surveys</h3>
            <div className="flex flex-col md:flex-row gap-2">
              <input
                type="text"
                placeholder="Search by name or village..."
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
                className="form-input md:w-64"
              />
              <button
                onClick={() => handleExport('csv')}
                className="btn-secondary text-sm"
              >
                Export CSV
              </button>
            </div>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-gray-100 border-b">
                <tr>
                  <th className="text-left p-3 font-semibold">Name</th>
                  <th className="text-left p-3 font-semibold hidden md:table-cell">Village</th>
                  <th className="text-left p-3 font-semibold hidden lg:table-cell">
                    Mobile
                  </th>
                  <th className="text-left p-3 font-semibold hidden md:table-cell">
                    Date
                  </th>
                  <th className="text-left p-3 font-semibold">Status</th>
                </tr>
              </thead>
              <tbody>
                {filteredSurveys.map((survey) => (
                  <tr key={survey._id} className="border-b hover:bg-gray-50">
                    <td className="p-3">
                      <span className="font-semibold">
                        {survey.phase1?.representativeFullName}
                      </span>
                      <p className="text-gray-600 text-xs md:hidden">
                        {survey.village?.name}
                      </p>
                    </td>
                    <td className="p-3 hidden md:table-cell">
                      {survey.village?.name}
                    </td>
                    <td className="p-3 hidden lg:table-cell">
                      {survey.phase1?.mobileNumber}
                    </td>
                    <td className="p-3 hidden md:table-cell">
                      {survey.submittedAt
                        ? new Date(survey.submittedAt).toLocaleDateString()
                        : '-'}
                    </td>
                    <td className="p-3">
                      <span className="badge badge-success">Completed</span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {filteredSurveys.length === 0 && (
            <div className="text-center py-8 text-gray-500">
              No surveys found matching your search.
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
