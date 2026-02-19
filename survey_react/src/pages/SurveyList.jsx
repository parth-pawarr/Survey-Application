import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store';
import { surveyAPI } from '../services/api';
import '../index.css';

export default function SurveyList() {
  const navigate = useNavigate();
  const { user, clearAuth } = useAuthStore();
  const [surveys, setSurveys] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!user) {
      navigate('/login');
      return;
    }
    fetchSurveys();
  }, []);

  const fetchSurveys = async () => {
    setLoading(true);
    try {
      const response = await surveyAPI.getSurveys(user?.id);
      setSurveys(response.data);
    } catch (err) {
      setError('Failed to load surveys');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    clearAuth();
    navigate('/login');
  };

  const handleNewSurvey = () => {
    navigate('/survey');
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mb-4"></div>
          <p className="text-gray-600">Loading surveys...</p>
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
              My Surveys
            </h1>
            <p className="text-gray-600">Surveyor: {user?.username}</p>
          </div>
          <div className="flex flex-col md:flex-row gap-2">
            <button onClick={handleNewSurvey} className="btn-primary">
              + New Survey
            </button>
            <button onClick={handleLogout} className="btn-secondary">
              Logout
            </button>
          </div>
        </div>
      </header>

      <main className="container-responsive">
        {error && (
          <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded my-4">
            {error}
          </div>
        )}

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 my-8">
          <div className="card">
            <p className="text-gray-600 text-sm">Total Surveys</p>
            <p className="text-3xl font-bold text-blue-600">{surveys.length}</p>
          </div>

          <div className="card">
            <p className="text-gray-600 text-sm">Completed</p>
            <p className="text-3xl font-bold text-green-600">
              {surveys.filter((s) => s.status === 'completed').length}
            </p>
          </div>

          <div className="card">
            <p className="text-gray-600 text-sm">Completion Rate</p>
            <p className="text-3xl font-bold text-purple-600">
              {surveys.length > 0
                ? Math.round(
                    (surveys.filter((s) => s.status === 'completed').length /
                      surveys.length) *
                      100
                  )
                : 0}
              %
            </p>
          </div>
        </div>

        {surveys.length > 0 ? (
          <div className="card">
            <h3 className="text-xl font-bold mb-6">Survey Records</h3>

            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-gray-100 border-b">
                  <tr>
                    <th className="text-left p-3 font-semibold">Family Name</th>
                    <th className="text-left p-3 font-semibold hidden md:table-cell">
                      Village
                    </th>
                    <th className="text-left p-3 font-semibold hidden lg:table-cell">
                      Mobile
                    </th>
                    <th className="text-left p-3 font-semibold hidden md:table-cell">
                      Family Size
                    </th>
                    <th className="text-left p-3 font-semibold">Date</th>
                    <th className="text-left p-3 font-semibold">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {surveys.map((survey) => (
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
                        {survey.phase1?.totalFamilyMembers}
                      </td>
                      <td className="p-3">
                        {survey.submittedAt
                          ? new Date(survey.submittedAt).toLocaleDateString('en-IN')
                          : '-'}
                      </td>
                      <td className="p-3">
                        <span className="badge badge-success">Submitted</span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        ) : (
          <div className="card text-center py-12">
            <p className="text-gray-600 mb-6">
              You haven't submitted any surveys yet.
            </p>
            <button onClick={handleNewSurvey} className="btn-primary">
              Start Your First Survey
            </button>
          </div>
        )}
      </main>
    </div>
  );
}
