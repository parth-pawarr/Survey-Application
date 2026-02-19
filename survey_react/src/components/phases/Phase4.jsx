import { useSurveyFormStore } from '../../store';

const EMPLOYMENT_TYPES = [
  'Farming',
  'Daily wage labor',
  'Government job',
  'Private job',
  'Self-employed',
  'Skilled labor',
  'Business owner',
  'Migrant worker',
  'Other',
];

const EDUCATION_LEVELS = [
  'Illiterate',
  'Primary',
  '10th Pass',
  '12th Pass',
  'Graduate',
  'Postgraduate',
];

const TRADITIONAL_SKILLS = [
  'Sutar (Carpenter)',
  'Lohar (Blacksmith)',
  'Kumbhar (Potter)',
  'Nhavi (Barber)',
  'Parit (Washerman)',
  'Gurav (Temple Servant)',
  'Joshi (Astrologer/Priest)',
  'Sonar (Goldsmith)',
  'Chambhar (Cobbler/Leather worker)',
  'Mali (Gardener)',
  'Mang (Village Messenger/Security)',
  'Teli (Oil Presser)',
];

const OTHER_SKILLS = [
  'Farming',
  'Mason',
  'Electrician',
  'Plumbing',
  'Driving',
  'Computer skills',
  'Mobile repair',
  'Handicrafts',
  'Cooking',
  'Other',
];

const UNEMPLOYMENT_REASONS = [
  'No skills',
  'Low education',
  'Health issue',
  'No job opportunities',
  'Financial problems',
  'Family responsibilities',
  'Migration issue',
  'Other',
];

export default function Phase4() {
  const {
    phase4,
    updatePhase4,
    addEmployedMember,
    removeEmployedMember,
    addUnemployedMember,
    removeUnemployedMember,
  } = useSurveyFormStore();

  const handleMainChange = (e) => {
    const { name, value } = e.target;
    updatePhase4({ [name]: value });
  };

  const handleAddEmployedMember = () => {
    addEmployedMember({
      name: '',
      age: '',
      gender: '',
      employmentType: '',
      otherEmploymentType: '',
    });
  };

  const updateEmployedMember = (index, field, value) => {
    const updated = [...phase4.employedMembers];
    updated[index] = { ...updated[index], [field]: value };
    updatePhase4({ employedMembers: updated });
  };

  const handleAddUnemployedMember = () => {
    addUnemployedMember({
      name: '',
      age: '',
      gender: '',
      educationLevel: '',
      skills: [],
      otherSkill: '',
      unemploymentReason: '',
      otherUnemploymentReason: '',
    });
  };

  const updateUnemployedMember = (index, field, value) => {
    const updated = [...phase4.unemployedMembers];
    updated[index] = { ...updated[index], [field]: value };
    updatePhase4({ unemployedMembers: updated });
  };

  const toggleSkill = (memberIndex, skill) => {
    const member = phase4.unemployedMembers[memberIndex];
    const skills = member.skills || [];
    const newSkills = skills.includes(skill)
      ? skills.filter((s) => s !== skill)
      : [...skills, skill];
    updateUnemployedMember(memberIndex, 'skills', newSkills);
  };

  return (
    <div className="card">
      <h2 className="phase-title">PHASE 4: Employment Section</h2>

      {/* Employed Members Section */}
      <div className="phase-subtitle">Employed Member Details</div>

      <div className="form-group">
        <label className="form-label">Is at least one member employed? *</label>
        <div className="space-y-2">
          {['Yes', 'No'].map((option) => (
            <label key={option} className="flex items-center">
              <input
                type="radio"
                name="hasEmployedMembers"
                value={option}
                checked={phase4.hasEmployedMembers === option}
                onChange={handleMainChange}
                className="mr-2 w-4 h-4"
                required
              />
              <span className="text-gray-700">{option}</span>
            </label>
          ))}
        </div>
      </div>

      {phase4.hasEmployedMembers === 'Yes' && (
        <div className="mt-6 bg-blue-50 p-4 rounded-lg mb-6">
          <p className="text-gray-700 font-semibold mb-4">
            Fill in details for each employed member:
          </p>

          {phase4.employedMembers.map((member, index) => (
            <div
              key={index}
              className="bg-white border border-gray-300 rounded-lg p-4 mb-4"
            >
              <div className="flex justify-between items-center mb-4">
                <h4 className="phase-subtitle">Employed Member {index + 1}</h4>
                <button
                  type="button"
                  onClick={() => removeEmployedMember(index)}
                  className="text-red-600 hover:text-red-800 font-semibold"
                >
                  Remove
                </button>
              </div>

              <div className="form-group">
                <label className="form-label">Name *</label>
                <input
                  type="text"
                  value={member.name}
                  onChange={(e) =>
                    updateEmployedMember(index, 'name', e.target.value)
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
                    updateEmployedMember(index, 'age', e.target.value)
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
                          updateEmployedMember(index, 'gender', e.target.value)
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
                <label className="form-label">Type of Employment *</label>
                <select
                  value={member.employmentType}
                  onChange={(e) =>
                    updateEmployedMember(index, 'employmentType', e.target.value)
                  }
                  className="form-select"
                  required
                >
                  <option value="">Select employment type</option>
                  {EMPLOYMENT_TYPES.map((type) => (
                    <option key={type} value={type}>
                      {type}
                    </option>
                  ))}
                </select>
              </div>

              {member.employmentType === 'Other' && (
                <div className="form-group">
                  <label className="form-label">Please specify *</label>
                  <input
                    type="text"
                    value={member.otherEmploymentType}
                    onChange={(e) =>
                      updateEmployedMember(
                        index,
                        'otherEmploymentType',
                        e.target.value
                      )
                    }
                    className="form-input"
                    placeholder="Specify employment type"
                    required
                  />
                </div>
              )}
            </div>
          ))}

          <button
            type="button"
            onClick={handleAddEmployedMember}
            className="btn-small bg-green-500 hover:bg-green-600"
          >
            + Add Another Employed Member
          </button>
        </div>
      )}

      <div className="section-divider"></div>

      {/* Unemployed Members Section */}
      <div className="phase-subtitle">Unemployed Member Details</div>

      <div className="mt-6 bg-yellow-50 p-4 rounded-lg">
        <p className="text-gray-700 font-semibold mb-4">
          Add details for unemployed members (if any):
        </p>

        {phase4.unemployedMembers.map((member, index) => (
          <div
            key={index}
            className="bg-white border border-gray-300 rounded-lg p-4 mb-4"
          >
            <div className="flex justify-between items-center mb-4">
              <h4 className="phase-subtitle">Unemployed Member {index + 1}</h4>
              <button
                type="button"
                onClick={() => removeUnemployedMember(index)}
                className="text-red-600 hover:text-red-800 font-semibold"
              >
                Remove
              </button>
            </div>

            <div className="form-group">
              <label className="form-label">Name *</label>
              <input
                type="text"
                value={member.name}
                onChange={(e) =>
                  updateUnemployedMember(index, 'name', e.target.value)
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
                  updateUnemployedMember(index, 'age', e.target.value)
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
                        updateUnemployedMember(index, 'gender', e.target.value)
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
              <label className="form-label">Highest Education Level *</label>
              <select
                value={member.educationLevel}
                onChange={(e) =>
                  updateUnemployedMember(index, 'educationLevel', e.target.value)
                }
                className="form-select"
                required
              >
                <option value="">Select education level</option>
                {EDUCATION_LEVELS.map((level) => (
                  <option key={level} value={level}>
                    {level}
                  </option>
                ))}
              </select>
            </div>

            <fieldset className="form-group">
              <label className="form-label">Skills Known *</label>
              <details className="mb-3">
                <summary className="cursor-pointer font-semibold text-blue-600">
                  Traditional 12 Balutedar Skills
                </summary>
                <div className="mt-3 ml-4 space-y-2">
                  {TRADITIONAL_SKILLS.map((skill) => (
                    <label key={skill} className="flex items-center">
                      <input
                        type="checkbox"
                        checked={member.skills.includes(skill)}
                        onChange={() => toggleSkill(index, skill)}
                        className="mr-2 w-4 h-4"
                      />
                      <span className="text-gray-700">{skill}</span>
                    </label>
                  ))}
                </div>
              </details>

              <details>
                <summary className="cursor-pointer font-semibold text-blue-600">
                  Other Skills
                </summary>
                <div className="mt-3 ml-4 space-y-2 max-h-48 overflow-y-auto">
                  {OTHER_SKILLS.map((skill) => (
                    <label key={skill} className="flex items-center">
                      <input
                        type="checkbox"
                        checked={member.skills.includes(skill)}
                        onChange={() => toggleSkill(index, skill)}
                        className="mr-2 w-4 h-4"
                      />
                      <span className="text-gray-700">{skill}</span>
                    </label>
                  ))}
                </div>
              </details>
            </fieldset>

            {member.skills.includes('Other') && (
              <div className="form-group">
                <label className="form-label">Please specify other skill *</label>
                <input
                  type="text"
                  value={member.otherSkill}
                  onChange={(e) =>
                    updateUnemployedMember(index, 'otherSkill', e.target.value)
                  }
                  className="form-input"
                  placeholder="Specify other skill"
                  required
                />
              </div>
            )}

            <div className="form-group">
              <label className="form-label">Main Reason for Unemployment *</label>
              <select
                value={member.unemploymentReason}
                onChange={(e) =>
                  updateUnemployedMember(
                    index,
                    'unemploymentReason',
                    e.target.value
                  )
                }
                className="form-select"
                required
              >
                <option value="">Select reason</option>
                {UNEMPLOYMENT_REASONS.map((reason) => (
                  <option key={reason} value={reason}>
                    {reason}
                  </option>
                ))}
              </select>
            </div>

            {member.unemploymentReason === 'Other' && (
              <div className="form-group">
                <label className="form-label">Please specify *</label>
                <input
                  type="text"
                  value={member.otherUnemploymentReason}
                  onChange={(e) =>
                    updateUnemployedMember(
                      index,
                      'otherUnemploymentReason',
                      e.target.value
                    )
                  }
                  className="form-input"
                  placeholder="Specify reason"
                  required
                />
              </div>
            )}
          </div>
        ))}

        <button
          type="button"
          onClick={handleAddUnemployedMember}
          className="btn-small bg-orange-500 hover:bg-orange-600"
        >
          + Add Unemployed Member
        </button>
      </div>
    </div>
  );
}
