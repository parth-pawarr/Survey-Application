import { useSurveyFormStore } from '../../store';

export default function Phase1() {
  const { phase1, updatePhase1 } = useSurveyFormStore();

  const handleChange = (e) => {
    const { name, value } = e.target;
    updatePhase1({ [name]: value });
  };

  return (
    <div className="card">
      <h2 className="phase-title">PHASE 1: Household Basic Information</h2>

      <div className="form-group">
        <label className="form-label">Representative Full Name *</label>
        <input
          type="text"
          name="representativeFullName"
          value={phase1.representativeFullName}
          onChange={handleChange}
          className="form-input"
          placeholder="Enter full name"
          required
        />
      </div>

      <div className="form-group">
        <label className="form-label">Mobile Number (WhatsApp Preferred) *</label>
        <input
          type="tel"
          name="mobileNumber"
          value={phase1.mobileNumber}
          onChange={handleChange}
          className="form-input"
          placeholder="10-digit number"
          pattern="\d{10}"
          maxLength="10"
          required
        />
      </div>

      <div className="form-group">
        <label className="form-label">Age *</label>
        <input
          type="number"
          name="age"
          value={phase1.age}
          onChange={handleChange}
          className="form-input"
          placeholder="Enter age"
          min="1"
          max="150"
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
                name="gender"
                value={option}
                checked={phase1.gender === option}
                onChange={handleChange}
                className="mr-2 w-4 h-4"
                required
              />
              <span className="text-gray-700">{option}</span>
            </label>
          ))}
        </div>
      </div>

      <div className="form-group">
        <label className="form-label">Total Family Members *</label>
        <input
          type="number"
          name="totalFamilyMembers"
          value={phase1.totalFamilyMembers}
          onChange={handleChange}
          className="form-input"
          placeholder="Enter number"
          min="1"
          required
        />
      </div>

      <div className="section-divider"></div>

      <div className="phase-subtitle">Ayushman Bharat Card Status</div>

      <div className="form-group">
        <label className="form-label">Do family members have an Ayushman Bharat card? *</label>
        <div className="space-y-2">
          {['All Members Have', 'Some Members Have', 'None Have'].map((option) => (
            <label key={option} className="flex items-center">
              <input
                type="radio"
                name="ayushmanCardStatus"
                value={option}
                checked={phase1.ayushmanCardStatus === option}
                onChange={handleChange}
                className="mr-2 w-4 h-4"
                required
              />
              <span className="text-gray-700">{option}</span>
            </label>
          ))}
        </div>
      </div>

      {phase1.ayushmanCardStatus === 'Some Members Have' && (
        <div className="form-group">
          <label className="form-label">How many members have the card? *</label>
          <input
            type="number"
            name="ayushmanCardCount"
            value={phase1.ayushmanCardCount}
            onChange={handleChange}
            className="form-input"
            placeholder="Enter number"
            min="1"
            required
          />
        </div>
      )}
    </div>
  );
}
