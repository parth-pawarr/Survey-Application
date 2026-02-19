defmodule RuralSurvey.Surveys.Phase2 do
  @moduledoc """
  Phase 2: Healthcare Section
  """

  alias RuralSurvey.Surveys.Phase2.AffectedMember

  @type t :: %__MODULE__{
          hasHealthIssues: String.t(),
          affectedMembers: [AffectedMember.t()]
        }

  defstruct [
    :hasHealthIssues,
    :affectedMembers
  ]

  @valid_yes_no ["Yes", "No"]

  def from_map(map) when is_map(map) do
    affected_members =
      (get_field(map, "affectedMembers", "affected_members") || [])
      |> Enum.map(&AffectedMember.from_map/1)

    %__MODULE__{
      hasHealthIssues: get_field(map, "hasHealthIssues", "has_health_issues"),
      affectedMembers: affected_members
    }
  end

  def to_map(%__MODULE__{} = phase2) do
    %{
      hasHealthIssues: phase2.hasHealthIssues,
      affectedMembers: Enum.map(phase2.affectedMembers || [], &AffectedMember.to_map/1)
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  def validate(%__MODULE__{} = phase2) do
    errors = []

    errors =
      if blank?(phase2.hasHealthIssues) or phase2.hasHealthIssues not in @valid_yes_no do
        [{:hasHealthIssues, "must be 'Yes' or 'No'"} | errors]
      else
        errors
      end

    errors =
      if phase2.hasHealthIssues == "Yes" do
        if Enum.empty?(phase2.affectedMembers || []) do
          [{:affectedMembers, "is required when hasHealthIssues is 'Yes'"} | errors]
        else
          validate_affected_members(phase2.affectedMembers, errors)
        end
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, phase2}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_affected_members(members, errors) do
    Enum.reduce(members, errors, fn member, acc ->
      case AffectedMember.validate(member) do
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

defmodule RuralSurvey.Surveys.Phase2.AffectedMember do
  @moduledoc """
  Affected member in Phase 2 (Healthcare)
  """

  @type t :: %__MODULE__{
          patientName: String.t(),
          age: integer(),
          gender: String.t(),
          healthIssueType: String.t(),
          otherHealthIssue: String.t() | nil,
          hasAdditionalMorbidity: String.t()
        }

  defstruct [
    :patientName,
    :age,
    :gender,
    :healthIssueType,
    :otherHealthIssue,
    :hasAdditionalMorbidity
  ]

  @valid_genders ["Male", "Female", "Other"]
  @valid_yes_no ["Yes", "No"]
  @valid_health_issue_types [
    "Diabetes",
    "Hypertension",
    "Heart Disease",
    "Asthma",
    "Tuberculosis",
    "Cancer",
    "Kidney Disease",
    "Disability",
    "Mental Health Issues",
    "Malnutrition",
    "Pregnancy-related complications",
    "Other"
  ]

  def from_map(map) when is_map(map) do
    %__MODULE__{
      patientName: get_field(map, "patientName", "patient_name"),
      age: get_integer(map, "age"),
      gender: get_field(map, "gender", "gender"),
      healthIssueType: get_field(map, "healthIssueType", "health_issue_type"),
      otherHealthIssue: get_field(map, "otherHealthIssue", "other_health_issue"),
      hasAdditionalMorbidity: get_field(map, "hasAdditionalMorbidity", "has_additional_morbidity")
    }
  end

  def to_map(%__MODULE__{} = member) do
    %{
      patientName: member.patientName,
      age: member.age,
      gender: member.gender,
      healthIssueType: member.healthIssueType,
      otherHealthIssue: member.otherHealthIssue,
      hasAdditionalMorbidity: member.hasAdditionalMorbidity
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  def validate(%__MODULE__{} = member) do
    errors = []

    errors =
      if blank?(member.patientName) do
        [{:patientName, "is required"} | errors]
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
      if blank?(member.healthIssueType) or member.healthIssueType not in @valid_health_issue_types do
        [{:healthIssueType, "must be one of: #{Enum.join(@valid_health_issue_types, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if member.healthIssueType == "Other" and blank?(member.otherHealthIssue) do
        [{:otherHealthIssue, "is required when healthIssueType is 'Other'"} | errors]
      else
        errors
      end

    errors =
      if blank?(member.hasAdditionalMorbidity) or
           member.hasAdditionalMorbidity not in @valid_yes_no do
        [{:hasAdditionalMorbidity, "must be 'Yes' or 'No'"} | errors]
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
