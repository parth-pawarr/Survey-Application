defmodule RuralSurvey.Surveys.Phase3 do
  @moduledoc """
  Phase 3: Education Section
  """

  alias RuralSurvey.Surveys.Phase3.Child

  @type t :: %__MODULE__{
          hasSchoolChildren: String.t(),
          children: [Child.t()]
        }

  defstruct [
    :hasSchoolChildren,
    :children
  ]

  @valid_yes_no ["Yes", "No"]

  def from_map(map) when is_map(map) do
    children =
      (get_field(map, "children", "children") || [])
      |> Enum.map(&Child.from_map/1)

    %__MODULE__{
      hasSchoolChildren: get_field(map, "hasSchoolChildren", "has_school_children"),
      children: children
    }
  end

  def to_map(%__MODULE__{} = phase3) do
    %{
      hasSchoolChildren: phase3.hasSchoolChildren,
      children: Enum.map(phase3.children || [], &Child.to_map/1)
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  def validate(%__MODULE__{} = phase3) do
    errors = []

    errors =
      if blank?(phase3.hasSchoolChildren) or phase3.hasSchoolChildren not in @valid_yes_no do
        [{:hasSchoolChildren, "must be 'Yes' or 'No'"} | errors]
      else
        errors
      end

    errors =
      if phase3.hasSchoolChildren == "Yes" do
        if Enum.empty?(phase3.children || []) do
          [{:children, "is required when hasSchoolChildren is 'Yes'"} | errors]
        else
          validate_children(phase3.children, errors)
        end
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, phase3}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_children(children, errors) do
    Enum.reduce(children, errors, fn child, acc ->
      case Child.validate(child) do
        {:ok, _} -> acc
        {:error, child_errors} -> child_errors ++ acc
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

defmodule RuralSurvey.Surveys.Phase3.Child do
  @moduledoc """
  Child in Phase 3 (Education)
  """

  @type t :: %__MODULE__{
          childName: String.t(),
          age: integer(),
          gender: String.t(),
          educationLevel: String.t(),
          hasFacingIssues: String.t(),
          educationalIssues: [String.t()],
          otherEducationalIssue: String.t() | nil,
          awareOfGovernmentSchemes: String.t()
        }

  defstruct [
    :childName,
    :age,
    :gender,
    :educationLevel,
    :hasFacingIssues,
    :educationalIssues,
    :otherEducationalIssue,
    :awareOfGovernmentSchemes
  ]

  @valid_genders ["Male", "Female", "Other"]
  @valid_yes_no ["Yes", "No"]
  @valid_scheme_awareness ["Yes", "No", "Heard but don't know details"]
  @valid_education_levels [
    "Not enrolled",
    "Anganwadi",
    "Primary",
    "Secondary",
    "Higher Secondary",
    "ITI / Diploma",
    "College",
    "Dropout"
  ]
  @valid_educational_issues [
    "Financial problem",
    "Transportation issue",
    "Poor academic performance",
    "Dropped out",
    "Lack of digital access",
    "Lack of books/material",
    "Health issue",
    "Family responsibility",
    "Other"
  ]

  def from_map(map) when is_map(map) do
    educational_issues = get_field(map, "educationalIssues", "educational_issues") || []
    educational_issues = if is_list(educational_issues), do: educational_issues, else: []

    %__MODULE__{
      childName: get_field(map, "childName", "child_name"),
      age: get_integer(map, "age"),
      gender: get_field(map, "gender", "gender"),
      educationLevel: get_field(map, "educationLevel", "education_level"),
      hasFacingIssues: get_field(map, "hasFacingIssues", "has_facing_issues"),
      educationalIssues: educational_issues,
      otherEducationalIssue: get_field(map, "otherEducationalIssue", "other_educational_issue"),
      awareOfGovernmentSchemes: get_field(map, "awareOfGovernmentSchemes", "aware_of_government_schemes")
    }
  end

  def to_map(%__MODULE__{} = child) do
    %{
      childName: child.childName,
      age: child.age,
      gender: child.gender,
      educationLevel: child.educationLevel,
      hasFacingIssues: child.hasFacingIssues,
      educationalIssues: child.educationalIssues || [],
      otherEducationalIssue: child.otherEducationalIssue,
      awareOfGovernmentSchemes: child.awareOfGovernmentSchemes
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  def validate(%__MODULE__{} = child) do
    errors = []

    errors =
      if blank?(child.childName) do
        [{:childName, "is required"} | errors]
      else
        errors
      end

    errors =
      if is_nil(child.age) or child.age < 0 do
        [{:age, "must be a positive number"} | errors]
      else
        errors
      end

    errors =
      if blank?(child.gender) or child.gender not in @valid_genders do
        [{:gender, "must be one of: #{Enum.join(@valid_genders, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if blank?(child.educationLevel) or child.educationLevel not in @valid_education_levels do
        [{:educationLevel, "must be one of: #{Enum.join(@valid_education_levels, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if blank?(child.hasFacingIssues) or child.hasFacingIssues not in @valid_yes_no do
        [{:hasFacingIssues, "must be 'Yes' or 'No'"} | errors]
      else
        errors
      end

    errors =
      if child.hasFacingIssues == "Yes" and
           ("Other" in (child.educationalIssues || []) and blank?(child.otherEducationalIssue)) do
        [{:otherEducationalIssue, "is required when 'Other' is selected in educationalIssues"} | errors]
      else
        errors
      end

    errors =
      if blank?(child.awareOfGovernmentSchemes) or
           child.awareOfGovernmentSchemes not in @valid_scheme_awareness do
        [{:awareOfGovernmentSchemes, "must be one of: #{Enum.join(@valid_scheme_awareness, ", ")}"} | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, child}
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
