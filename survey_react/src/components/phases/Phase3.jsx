import { useSurveyFormStore } from '../../store';

const EDUCATION_LEVELS = [
  'Not enrolled',
  'Anganwadi',
  'Primary',
  'Secondary',
  'Higher Secondary',
  'ITI / Diploma',
  'College',
  'Dropout',
];

const EDUCATIONAL_ISSUES = [
  'Financial problem',
  'Transportation issue',
  'Poor academic performance',
  'Dropped out',
  'Lack of digital access',
  'Lack of books/material',
  'Health issue',
  'Family responsibility',
  'Other',
];

export default function Phase3() {
  const { phase3, updatePhase3, addChild, removeChild } = useSurveyFormStore();

  const handleMainChange = (e) => {
    const { name, value } = e.target;
    updatePhase3({ [name]: value });
  };

  const handleAddChild = () => {
    addChild({
      childName: '',
      age: '',
      gender: '',
      educationLevel: '',
      hasFacingIssues: 'No',
      educationalIssues: [],
      otherEducationalIssue: '',
      awareOfSchemes: 'No',
    });
  };

  const updateChild = (index, field, value) => {
    const updated = [...phase3.children];
    updated[index] = { ...updated[index], [field]: value };
    updatePhase3({ children: updated });
  };

  const toggleIssue = (childIndex, issue) => {
    const child = phase3.children[childIndex];
    const issues = child.educationalIssues || [];
    const newIssues = issues.includes(issue)
      ? issues.filter((i) => i !== issue)
      : [...issues, issue];
    updateChild(childIndex, 'educationalIssues', newIssues);
  };

  return (
    <div className="card">
      <h2 className="phase-title">PHASE 3: Education Section</h2>

      <div className="form-group">
        <label className="form-label">
          Are there school/college-going children in the household? *
        </label>
        <div className="space-y-2">
          {['Yes', 'No'].map((option) => (
            <label key={option} className="flex items-center">
              <input
                type="radio"
                name="hasSchoolChildren"
                value={option}
                checked={phase3.hasSchoolChildren === option}
                onChange={handleMainChange}
                className="mr-2 w-4 h-4"
                required
              />
              <span className="text-gray-700">{option}</span>
            </label>
          ))}
        </div>
      </div>

      {phase3.hasSchoolChildren === 'Yes' && (
        <div className="mt-6">
          <div className="bg-blue-50 p-4 rounded-lg mb-4">
            <p className="text-gray-700 font-semibold mb-4">
              Fill in details for each child:
            </p>

            {phase3.children.map((child, index) => (
              <div
                key={index}
                className="bg-white border border-gray-300 rounded-lg p-4 mb-4"
              >
                <div className="flex justify-between items-center mb-4">
                  <h4 className="phase-subtitle">Child {index + 1}</h4>
                  <button
                    type="button"
                    onClick={() => removeChild(index)}
                    className="text-red-600 hover:text-red-800 font-semibold"
                  >
                    Remove
                  </button>
                </div>

                <div className="form-group">
                  <label className="form-label">Child Name *</label>
                  <input
                    type="text"
                    value={child.childName}
                    onChange={(e) =>
                      updateChild(index, 'childName', e.target.value)
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
                    value={child.age}
                    onChange={(e) =>
                      updateChild(index, 'age', e.target.value)
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
                          checked={child.gender === option}
                          onChange={(e) =>
                            updateChild(index, 'gender', e.target.value)
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
                  <label className="form-label">Current Education Level *</label>
                  <select
                    value={child.educationLevel}
                    onChange={(e) =>
                      updateChild(index, 'educationLevel', e.target.value)
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

                <div className="form-group">
                  <label className="form-label">
                    Is the child facing any educational issues? *
                  </label>
                  <div className="space-y-2">
                    {['Yes', 'No'].map((option) => (
                      <label key={option} className="flex items-center">
                        <input
                          type="radio"
                          value={option}
                          checked={child.hasFacingIssues === option}
                          onChange={(e) =>
                            updateChild(index, 'hasFacingIssues', e.target.value)
                          }
                          className="mr-2 w-4 h-4"
                          required
                        />
                        <span className="text-gray-700">{option}</span>
                      </label>
                    ))}
                  </div>
                </div>

                {child.hasFacingIssues === 'Yes' && (
                  <div className="form-group">
                    <label className="form-label">Type of Educational Issue *</label>
                    <div className="space-y-2 max-h-48 overflow-y-auto">
                      {EDUCATIONAL_ISSUES.map((issue) => (
                        <label key={issue} className="flex items-center">
                          <input
                            type="checkbox"
                            checked={child.educationalIssues.includes(issue)}
                            onChange={() => toggleIssue(index, issue)}
                            className="mr-2 w-4 h-4"
                          />
                          <span className="text-gray-700">{issue}</span>
                        </label>
                      ))}
                    </div>
                  </div>
                )}

                {child.hasFacingIssues === 'Yes' &&
                  child.educationalIssues.includes('Other') && (
                    <div className="form-group">
                      <label className="form-label">Please specify *</label>
                      <input
                        type="text"
                        value={child.otherEducationalIssue}
                        onChange={(e) =>
                          updateChild(
                            index,
                            'otherEducationalIssue',
                            e.target.value
                          )
                        }
                        className="form-input"
                        placeholder="Specify other issue"
                        required
                      />
                    </div>
                  )}

                <div className="form-group">
                  <label className="form-label">
                    Is the family aware of government education schemes? *
                  </label>
                  <div className="space-y-2">
                    {['Yes', 'No', 'Heard but don\'t know details'].map(
                      (option) => (
                        <label key={option} className="flex items-center">
                          <input
                            type="radio"
                            value={option}
                            checked={child.awareOfSchemes === option}
                            onChange={(e) =>
                              updateChild(index, 'awareOfSchemes', e.target.value)
                            }
                            className="mr-2 w-4 h-4"
                            required
                          />
                          <span className="text-gray-700">{option}</span>
                        </label>
                      )
                    )}
                  </div>
                </div>
              </div>
            ))}

            <button
              type="button"
              onClick={handleAddChild}
              className="btn-small bg-green-500 hover:bg-green-600"
            >
              + Add Another Child
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
