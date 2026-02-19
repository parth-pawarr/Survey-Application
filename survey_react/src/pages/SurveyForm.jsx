import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSurveyFormStore, useAuthStore } from '../store';
import { surveyAPI, villageAPI } from '../services/api';
import Phase1 from '../components/phases/Phase1';
import Phase2 from '../components/phases/Phase2';
import Phase3 from '../components/phases/Phase3';
import Phase4 from '../components/phases/Phase4';
import '../index.css';

export default function SurveyForm() {
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const {
    currentPhase,
    setCurrentPhase,
    village,
    setVillage,
    getFormData,
    resetForm,
  } = useSurveyFormStore();

  const [villages, setVillages] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    fetchVillages();
  }, []);

  const fetchVillages = async () => {
    try {
      const response = await villageAPI.getVillages();
      setVillages(response.data.villages || []);
    } catch (err) {
      console.error('Error fetching villages:', err);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      if (!village) {
        setError('Please select a village');
        setLoading(false);
        return;
      }

      const formData = getFormData();
      const surveyData = {
        ...formData,
        village,
        surveyorId: user?.id,
        submittedAt: new Date().toISOString(),
      };

      await surveyAPI.submitSurvey(surveyData);

      setSuccess('Survey submitted successfully!');
      resetForm();
      setVillage('');
      setCurrentPhase(1);

      setTimeout(() => {
        navigate('/survey-list');
      }, 2000);
    } catch (err) {
      setError(
        err.response?.data?.message || 'Error submitting survey. Please try again.'
      );
    } finally {
      setLoading(false);
    }
  };

  const handlePrevious = () => {
    if (currentPhase > 1) {
      setCurrentPhase(currentPhase - 1);
      window.scrollTo(0, 0);
    }
  };

  const handleNext = () => {
    if (currentPhase < 4) {
      setCurrentPhase(currentPhase + 1);
      window.scrollTo(0, 0);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 py-4">
      <div className="container-responsive">
        <div className="bg-white rounded-lg shadow-lg p-4 md:p-8">
          {/* Header */}
          <div className="text-center mb-8">
            <h1 className="text-2xl md:text-3xl font-bold text-gray-800 mb-2">
              Household Survey Form
            </h1>
            <p className="text-gray-600">
              Surveyor: <span className="font-semibold">{user?.username}</span>
            </p>
          </div>

          {/* Village Selection */}
          <div className="card">
            <label className="form-label text-lg">Select Village *</label>
            <select
              value={village}
              onChange={(e) => setVillage(e.target.value)}
              className="form-select"
            //   required
            >
              <option value="">-- Select a village --</option>
              {villages.map((v) => (
                <option key={v._id} value={v._id}>
                  {v.name}
                </option>
              ))}
            </select>
          </div>

          {/* Progress Bar */}
          <div className="card">
            <div className="flex justify-between items-center mb-4">
              {[1, 2, 3, 4].map((phase) => (
                <div
                  key={phase}
                  className={`flex flex-col items-center flex-1 ${
                    phase !== 4 ? 'pb-4' : ''
                  }`}
                >
                  <div
                    className={`w-10 h-10 md:w-12 md:h-12 rounded-full flex items-center justify-center font-bold text-white mb-2 ${
                      currentPhase >= phase
                        ? 'bg-blue-500'
                        : 'bg-gray-300'
                    }`}
                  >
                    {phase}
                  </div>
                  <p className="text-xs md:text-sm text-center">
                    {phase === 1 && 'Basic Info'}
                    {phase === 2 && 'Healthcare'}
                    {phase === 3 && 'Education'}
                    {phase === 4 && 'Employment'}
                  </p>
                  {phase !== 4 && (
                    <div
                      className={`w-1 h-8 md:h-12 mt-2 ${
                        currentPhase > phase ? 'bg-blue-500' : 'bg-gray-300'
                      }`}
                    ></div>
                  )}
                </div>
              ))}
            </div>
          </div>

          {/* Error Message */}
          {error && (
            <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded mb-4">
              {error}
            </div>
          )}

          {/* Success Message */}
          {success && (
            <div className="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded mb-4">
              {success}
            </div>
          )}

          {/* Form Content */}
          <form onSubmit={handleSubmit}>
            {currentPhase === 1 && <Phase1 />}
            {currentPhase === 2 && <Phase2 />}
            {currentPhase === 3 && <Phase3 />}
            {currentPhase === 4 && <Phase4 />}

            {/* Navigation Buttons */}
            <div className="flex flex-col md:flex-row justify-between gap-4 mt-8">
              <button
                type="button"
                onClick={handlePrevious}
                disabled={currentPhase === 1 || loading}
                className={`btn-secondary ${
                  currentPhase === 1 || loading
                    ? 'opacity-50 cursor-not-allowed'
                    : ''
                }`}
              >
                ← Previous
              </button>

              {currentPhase < 4 ? (
                <button
                  type="button"
                  onClick={handleNext}
                  disabled={loading}
                  className="btn-primary"
                >
                  Next →
                </button>
              ) : (
                <button
                  type="submit"
                  disabled={loading || !village}
                  className={`btn-primary ${
                    loading || !village ? 'opacity-50 cursor-not-allowed' : ''
                  }`}
                >
                  {loading ? 'Submitting...' : 'Submit Survey'}
                </button>
              )}
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}
