import { useSurveyFormStore } from '../../store';

const HEALTH_ISSUES = [
  'Diabetes',
  'Hypertension',
  'Heart Disease',
  'Asthma',
  'Tuberculosis',
  'Cancer',
  'Kidney Disease',
  'Disability',
  'Mental Health Issues',
  'Malnutrition',
  'Pregnancy-related complications',
  'Other',
];

export default function Phase2() {
  const { phase2, updatePhase2, addAffectedMember, removeAffectedMember } =
    useSurveyFormStore();

  const handleMainChange = (e) => {
    const { name, value } = e.target;
    updatePhase2({ [name]: value });
  };

  const handleAddMember = () => {
    addAffectedMember({
      patientName: '',
      age: '',
      gender: '',
      healthIssueType: '',
      otherHealthIssue: '',
      hasAdditionalMorbidity: 'No',
    });
  };

  const updateAffectedMember = (index, field, value) => {
    const updated = [...phase2.affectedMembers];
    updated[index] = { ...updated[index], [field]: value };
    updatePhase2({ affectedMembers: updated });
  };

  return (
    <div className="card">
      <h2 className="phase-title">PHASE 2: Healthcare Section</h2>

      <div className="form-group">
        <label className="form-label">
          Is anyone in the household currently facing health issues? *
        </label>
        <div className="space-y-2">
          {['Yes', 'No'].map((option) => (
            <label key={option} className="flex items-center">
              <input
                type="radio"
                name="hasHealthIssues"
                value={option}
                checked={phase2.hasHealthIssues === option}
                onChange={handleMainChange}
                className="mr-2 w-4 h-4"
                required
              />
              <span className="text-gray-700">{option}</span>
            </label>
          ))}
        </div>
      </div>

      {phase2.hasHealthIssues === 'Yes' && (
        <div className="mt-6">
          <div className="bg-blue-50 p-4 rounded-lg mb-4">
            <p className="text-gray-700 font-semibold mb-4">
              Fill in details for each affected member:
            </p>

            {phase2.affectedMembers.map((member, index) => (
              <div
                key={index}
                className="bg-white border border-gray-300 rounded-lg p-4 mb-4"
              >
                <div className="flex justify-between items-center mb-4">
                  <h4 className="phase-subtitle">Member {index + 1}</h4>
                  <button
                    type="button"
                    onClick={() => removeAffectedMember(index)}
                    className="text-red-600 hover:text-red-800 font-semibold"
                  >
                    Remove
                  </button>
                </div>

                <div className="form-group">
                  <label className="form-label">Patient Name *</label>
                  <input
                    type="text"
                    value={member.patientName}
                    onChange={(e) =>
                      updateAffectedMember(index, 'patientName', e.target.value)
                    }
                    className="form-input"
                    placeholder="Enter name"
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Age *</label>
                  <input
                    type="number"
                    value={member.age}
                    onChange={(e) =>
                      updateAffectedMember(index, 'age', e.target.value)
                    }
                    className="form-input"
                    placeholder="Enter age"
                    min="1"
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Gender *</label>
                  <div className="space-y-2">
                    {['Male', 'Female', 'Other'].map((option) => (
                      <label key={option} className="flex items-center">
                        <input
                          type="radio"
                          value={option}
                          checked={member.gender === option}
                          onChange={(e) =>
                            updateAffectedMember(index, 'gender', e.target.value)
                          }
                          className="mr-2 w-4 h-4"
                          required
                        />
                        <span className="text-gray-700">{option}</span>
                      </label>
                    ))}
                  </div>
                </div>

                <div className="form-group">
                  <label className="form-label">Type of Health Issue *</label>
                  <select
                    value={member.healthIssueType}
                    onChange={(e) =>
                      updateAffectedMember(index, 'healthIssueType', e.target.value)
                    }
                    className="form-select"
                    required
                  >
                    <option value="">Select health issue</option>
                    {HEALTH_ISSUES.map((issue) => (
                      <option key={issue} value={issue}>
                        {issue}
                      </option>
                    ))}
                  </select>
                </div>

                {member.healthIssueType === 'Other' && (
                  <div className="form-group">
                    <label className="form-label">Please specify *</label>
                    <input
                      type="text"
                      value={member.otherHealthIssue}
                      onChange={(e) =>
                        updateAffectedMember(index, 'otherHealthIssue', e.target.value)
                      }
                      className="form-input"
                      placeholder="Specify other health issue"
                      required
                    />
                  </div>
                )}

                <div className="form-group">
                  <label className="form-label">
                    Is there any kind of morbidity or any other health problem?
                    (Aur koi takleef hai kya?) *
                  </label>
                  <div className="space-y-2">
                    {['Yes', 'No'].map((option) => (
                      <label key={option} className="flex items-center">
                        <input
                          type="radio"
                          value={option}
                          checked={member.hasAdditionalMorbidity === option}
                          onChange={(e) =>
                            updateAffectedMember(
                              index,
                              'hasAdditionalMorbidity',
                              e.target.value
                            )
                          }
                          className="mr-2 w-4 h-4"
                          required
                        />
                        <span className="text-gray-700">{option}</span>
                      </label>
                    ))}
                  </div>
                </div>
              </div>
            ))}

            <button
              type="button"
              onClick={handleAddMember}
              className="btn-small bg-green-500 hover:bg-green-600"
            >
              + Add Another Member
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
