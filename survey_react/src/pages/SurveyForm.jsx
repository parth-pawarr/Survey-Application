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

  // const fetchVillages = async () => {
  //   try {
  //     const response = await villageAPI.getVillages();
  //     setVillages(response.data.villages || []);
  //   } catch (err) {
  //     console.error('Error fetching villages:', err);
  //   }
  // };

  const fetchVillages = async () => {
  try {
    const response = await villageAPI.getVillages();
    setVillages(response.data.villages || []);
  } catch (err) {
    console.error('Error fetching villages:', err);
    // If needed, hardcode with proper _id fields, not plain strings
    setVillages([
      { _id: "actual_mongo_id_1", name: "Nashik" },
      { _id: "actual_mongo_id_2", name: "Ozar" },
    ]);
  }
};



  const validateFormData = (formData) => {
    const errors = [];

    // Validate Phase 1
    if (!formData.phase1.representativeFullName?.trim()) {
      errors.push('Representative full name is required');
    }
    if (!formData.phase1.mobileNumber?.trim()) {
      errors.push('Mobile number is required');
    } else if (!/^\d{10}$/.test(formData.phase1.mobileNumber)) {
      errors.push('Mobile number must be 10 digits');
    }
    if (!formData.phase1.age) {
      errors.push('Age is required');
    }
    if (!formData.phase1.gender) {
      errors.push('Gender is required');
    }
    if (!formData.phase1.totalFamilyMembers) {
      errors.push('Total family members is required');
    }
    if (!formData.phase1.ayushmanCardStatus) {
      errors.push('Ayushman card status is required');
    }
    if (
      formData.phase1.ayushmanCardStatus === 'Some Members Have' &&
      !formData.phase1.ayushmanCardCount
    ) {
      errors.push('Please specify how many members have the Ayushman card');
    }

    return errors;
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

      // Client-side validation
      const validationErrors = validateFormData(formData);
      if (validationErrors.length > 0) {
        setError(validationErrors.join('\n'));
        setLoading(false);
        return;
      }

      const surveyData = {
        village_id: village,
        phase1: {
          representativeFullName: formData.phase1.representativeFullName,
          mobileNumber: formData.phase1.mobileNumber,
          age: parseInt(formData.phase1.age),
          gender: formData.phase1.gender,
          totalFamilyMembers: parseInt(formData.phase1.totalFamilyMembers),
          ayushmanCardStatus: formData.phase1.ayushmanCardStatus,
          ayushmanCardCount: parseInt(formData.phase1.ayushmanCardCount) || 0
        },
        phase2: formData.phase2,
        phase3: formData.phase3,
        phase4: formData.phase4,
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
      // Better error handling for API responses
      let errorMessage = 'Error submitting survey. Please try again.';
      
      if (err.response?.data?.errors) {
        const apiErrors = err.response.data.errors;
        if (Array.isArray(apiErrors)) {
          errorMessage = apiErrors.join('\n');
        } else if (typeof apiErrors === 'object') {
          errorMessage = Object.entries(apiErrors)
            .map(([key, value]) => `${key}: ${value}`)
            .join('\n');
        } else if (typeof apiErrors === 'string') {
          errorMessage = apiErrors;
        }
      } else if (err.response?.data?.message) {
        errorMessage = err.response.data.message;
      }
      
      setError(errorMessage);
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
              <p className="font-semibold mb-2">❌ Submission Error:</p>
              <div className="whitespace-pre-line text-sm">
                {error}
              </div>
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
