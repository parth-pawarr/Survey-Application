defmodule RuralSurvey.Surveys.Phase4 do
  @moduledoc """
  Phase 4: Employment Section
  """

  @derive Jason.Encoder
  alias RuralSurvey.Surveys.Phase4.EmployedMember
  alias RuralSurvey.Surveys.Phase4.UnemployedMember

  @type t :: %__MODULE__{
          hasEmployedMembers: String.t(),
          employedMembers: [EmployedMember.t()],
          unemployedMembers: [UnemployedMember.t()]
        }

  defstruct [
    :hasEmployedMembers,
    :employedMembers,
    :unemployedMembers
  ]

  @valid_yes_no ["Yes", "No"]

  def from_map(map) when is_map(map) do
    employed_members =
      (get_field(map, "employedMembers", "employed_members") || [])
      |> Enum.map(&EmployedMember.from_map/1)

    unemployed_members =
      (get_field(map, "unemployedMembers", "unemployed_members") || [])
      |> Enum.map(&UnemployedMember.from_map/1)

    %__MODULE__{
      hasEmployedMembers: get_field(map, "hasEmployedMembers", "has_employed_members"),
      employedMembers: employed_members,
      unemployedMembers: unemployed_members
    }
  end

  def to_map(%__MODULE__{} = phase4) do
    %{
      hasEmployedMembers: phase4.hasEmployedMembers,
      employedMembers: Enum.map(phase4.employedMembers || [], &EmployedMember.to_map/1),
      unemployedMembers: Enum.map(phase4.unemployedMembers || [], &UnemployedMember.to_map/1)
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  def validate(%__MODULE__{} = phase4) do
    errors = []

    errors =
      if blank?(phase4.hasEmployedMembers) or phase4.hasEmployedMembers not in @valid_yes_no do
        [{:hasEmployedMembers, "must be 'Yes' or 'No'"} | errors]
      else
        errors
      end

    errors =
      if phase4.hasEmployedMembers == "Yes" do
        if Enum.empty?(phase4.employedMembers || []) do
          [{:employedMembers, "is required when hasEmployedMembers is 'Yes'"} | errors]
        else
          validate_employed_members(phase4.employedMembers, errors)
        end
      else
        errors
      end

    errors = validate_unemployed_members(phase4.unemployedMembers || [], errors)

    if Enum.empty?(errors) do
      {:ok, phase4}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_employed_members(members, errors) do
    Enum.reduce(members, errors, fn member, acc ->
      case EmployedMember.validate(member) do
        {:ok, _} -> acc
        {:error, member_errors} -> member_errors ++ acc
      end
    end)
  end

  defp validate_unemployed_members(members, errors) do
    Enum.reduce(members, errors, fn member, acc ->
      case UnemployedMember.validate(member) do
        {:ok, _} -> acc
        {:error, member_errors} -> member_errors ++ acc
      end
    end)
  end

  defp get_field(map, camel_key, snake_key) do
    Map.get(map, String.to_atom(camel_key)) ||
      Map.get(map, camel_key) ||
      Map.get(map, String.to_atom(snake_key)) ||
      Map.get(map, snake_key)
  end

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(val) when is_binary(val), do: String.trim(val) == ""
  defp blank?(_), do: false
end

defmodule RuralSurvey.Surveys.Phase4.EmployedMember do
  @moduledoc """
  Employed member in Phase 4 (Employment)
  """

  @derive Jason.Encoder
  alias RuralSurvey.Surveys.Phase4

  @type t :: %__MODULE__{
          name: String.t(),
          age: integer(),
          gender: String.t(),
          employmentType: String.t(),
          otherEmploymentType: String.t() | nil
        }

  defstruct [
    :name,
    :age,
    :gender,
    :employmentType,
    :otherEmploymentType
  ]

  @valid_genders ["Male", "Female", "Other"]
  @valid_employment_types [
    "Farming",
    "Daily wage labor",
    "Government job",
    "Private job",
    "Self-employed",
    "Skilled labor",
    "Business owner",
    "Migrant worker",
    "Other"
  ]

  def from_map(map) when is_map(map) do
    %__MODULE__{
      name: get_field(map, "name", "name"),
      age: get_integer(map, "age"),
      gender: get_field(map, "gender", "gender"),
      employmentType: get_field(map, "employmentType", "employment_type"),
      otherEmploymentType: get_field(map, "otherEmploymentType", "other_employment_type")
    }
  end

  def to_map(%__MODULE__{} = member) do
    %{
      name: member.name,
      age: member.age,
      gender: member.gender,
      employmentType: member.employmentType,
      otherEmploymentType: member.otherEmploymentType
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  def validate(%__MODULE__{} = member) do
    errors = []

    errors =
      if blank?(member.name) do
        [{:name, "is required"} | errors]
      else
        errors
      end

    errors =
      if is_nil(member.age) or member.age < 0 do
        [{:age, "must be a positive number"} | errors]
      else
        errors
      end

    errors =
      if blank?(member.gender) or member.gender not in @valid_genders do
        [{:gender, "must be one of: #{Enum.join(@valid_genders, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if blank?(member.employmentType) or member.employmentType not in @valid_employment_types do
        [{:employmentType, "must be one of: #{Enum.join(@valid_employment_types, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if member.employmentType == "Other" and blank?(member.otherEmploymentType) do
        [{:otherEmploymentType, "is required when employmentType is 'Other'"} | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, member}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp get_field(map, camel_key, snake_key) do
    Map.get(map, String.to_atom(camel_key)) ||
      Map.get(map, camel_key) ||
      Map.get(map, String.to_atom(snake_key)) ||
      Map.get(map, snake_key)
  end

  defp get_integer(map, key) do
    case get_field(map, key, key) do
      nil -> nil
      val when is_integer(val) -> val
      val when is_binary(val) -> String.to_integer(val)
      _ -> nil
    end
  end

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(val) when is_binary(val), do: String.trim(val) == ""
  defp blank?(_), do: false
end

defmodule RuralSurvey.Surveys.Phase4.UnemployedMember do
  @moduledoc """
  Unemployed member in Phase 4 (Employment)
  """

  @derive Jason.Encoder
  alias RuralSurvey.Surveys.Phase4

  @type t :: %__MODULE__{
          name: String.t(),
          age: integer(),
          gender: String.t(),
          educationLevel: String.t(),
          skills: [String.t()],
          otherSkill: String.t() | nil,
          unemploymentReason: String.t(),
          otherUnemploymentReason: String.t() | nil
        }

  defstruct [
    :name,
    :age,
    :gender,
    :educationLevel,
    :skills,
    :otherSkill,
    :unemploymentReason,
    :otherUnemploymentReason
  ]

  @valid_genders ["Male", "Female", "Other"]
  @valid_education_levels [
    "Illiterate",
    "Primary",
    "10th Pass",
    "12th Pass",
    "Graduate",
    "Postgraduate"
  ]
  @valid_skills [
    # Traditional 12 Balutedar Skills
    "Sutar (Carpenter)",
    "Lohar (Blacksmith)",
    "Kumbhar (Potter)",
    "Nhavi (Barber)",
    "Parit (Washerman)",
    "Gurav (Temple Servant)",
    "Joshi (Astrologer/Priest)",
    "Sonar (Goldsmith)",
    "Chambhar (Cobbler/Leather worker)",
    "Mali (Gardener)",
    "Mang (Village Messenger/Security)",
    "Teli (Oil Presser)",
    # Other Skills
    "Farming",
    "Mason",
    "Electrician",
    "Plumbing",
    "Driving",
    "Computer skills",
    "Mobile repair",
    "Handicrafts",
    "Cooking",
    "Other"
  ]
  @valid_unemployment_reasons [
    "No skills",
    "Low education",
    "Health issue",
    "No job opportunities",
    "Financial problems",
    "Family responsibilities",
    "Migration issue",
    "Other"
  ]

  def from_map(map) when is_map(map) do
    skills = get_field(map, "skills", "skills") || []
    skills = if is_list(skills), do: skills, else: []

    %__MODULE__{
      name: get_field(map, "name", "name"),
      age: get_integer(map, "age"),
      gender: get_field(map, "gender", "gender"),
      educationLevel: get_field(map, "educationLevel", "education_level"),
      skills: skills,
      otherSkill: get_field(map, "otherSkill", "other_skill"),
      unemploymentReason: get_field(map, "unemploymentReason", "unemployment_reason"),
      otherUnemploymentReason: get_field(map, "otherUnemploymentReason", "other_unemployment_reason")
    }
  end

  def to_map(%__MODULE__{} = member) do
    %{
      name: member.name,
      age: member.age,
      gender: member.gender,
      educationLevel: member.educationLevel,
      skills: member.skills || [],
      otherSkill: member.otherSkill,
      unemploymentReason: member.unemploymentReason,
      otherUnemploymentReason: member.otherUnemploymentReason
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  def validate(%__MODULE__{} = member) do
    errors = []

    errors =
      if blank?(member.name) do
        [{:name, "is required"} | errors]
      else
        errors
      end

    errors =
      if is_nil(member.age) or member.age < 0 do
        [{:age, "must be a positive number"} | errors]
      else
        errors
      end

    errors =
      if blank?(member.gender) or member.gender not in @valid_genders do
        [{:gender, "must be one of: #{Enum.join(@valid_genders, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if blank?(member.educationLevel) or member.educationLevel not in @valid_education_levels do
        [{:educationLevel, "must be one of: #{Enum.join(@valid_education_levels, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if "Other" in (member.skills || []) and blank?(member.otherSkill) do
        [{:otherSkill, "is required when 'Other' is selected in skills"} | errors]
      else
        errors
      end

    errors =
      if blank?(member.unemploymentReason) or member.unemploymentReason not in @valid_unemployment_reasons do
        [{:unemploymentReason, "must be one of: #{Enum.join(@valid_unemployment_reasons, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if member.unemploymentReason == "Other" and blank?(member.otherUnemploymentReason) do
        [{:otherUnemploymentReason, "is required when unemploymentReason is 'Other'"} | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, member}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp get_field(map, camel_key, snake_key) do
    Map.get(map, String.to_atom(camel_key)) ||
      Map.get(map, camel_key) ||
      Map.get(map, String.to_atom(snake_key)) ||
      Map.get(map, snake_key)
  end

  defp get_integer(map, key) do
    case get_field(map, key, key) do
      nil -> nil
      val when is_integer(val) -> val
      val when is_binary(val) -> String.to_integer(val)
      _ -> nil
    end
  end

  defp blank?(nil), do: true
  defp blank?(""), do: true
  defp blank?(val) when is_binary(val), do: String.trim(val) == ""
  defp blank?(_), do: false
end
