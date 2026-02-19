defmodule RuralSurvey.Surveys.Phase1 do
  @moduledoc """
  Phase 1: Household Basic Information
  """

  @type t :: %__MODULE__{
          representativeFullName: String.t(),
          mobileNumber: String.t(),
          age: integer(),
          gender: String.t(),
          totalFamilyMembers: integer(),
          ayushmanCardStatus: String.t(),
          ayushmanCardCount: integer() | nil
        }

  defstruct [
    :representativeFullName,
    :mobileNumber,
    :age,
    :gender,
    :totalFamilyMembers,
    :ayushmanCardStatus,
    :ayushmanCardCount
  ]

  @valid_genders ["Male", "Female", "Other"]
  @valid_card_statuses ["All Members Have", "Some Members Have", "None Have"]

  @doc """
  Creates a Phase1 struct from a map (typically from MongoDB or JSON).
  Handles both snake_case and camelCase keys.
  """
  def from_map(map) when is_map(map) do
    %__MODULE__{
      representativeFullName: get_field(map, "representativeFullName", "representative_full_name"),
      mobileNumber: get_field(map, "mobileNumber", "mobile_number"),
      age: get_integer(map, "age"),
      gender: get_field(map, "gender"),
      totalFamilyMembers: get_integer(map, "totalFamilyMembers", "total_family_members"),
      ayushmanCardStatus: get_field(map, "ayushmanCardStatus", "ayushman_bharat_card_status"),
      ayushmanCardCount: get_integer(map, "ayushmanCardCount", "ayushman_bharat_card_count")
    }
  end

  @doc """
  Converts Phase1 struct to a map suitable for MongoDB insertion.
  """
  def to_map(%__MODULE__{} = phase1) do
    %{
      representativeFullName: phase1.representativeFullName,
      mobileNumber: phase1.mobileNumber,
      age: phase1.age,
      gender: phase1.gender,
      totalFamilyMembers: phase1.totalFamilyMembers,
      ayushmanCardStatus: phase1.ayushmanCardStatus,
      ayushmanCardCount: phase1.ayushmanCardCount
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  @doc """
  Validates Phase1 data.
  Returns {:ok, phase1} or {:error, [errors]}.
  """
  def validate(%__MODULE__{} = phase1) do
    errors = []

    errors =
      if blank?(phase1.representativeFullName) do
        [{:representativeFullName, "is required"} | errors]
      else
        errors
      end

    errors =
      if blank?(phase1.mobileNumber) do
        [{:mobileNumber, "is required"} | errors]
      else
        validate_mobile_number(phase1.mobileNumber, errors)
      end

    errors =
      if is_nil(phase1.age) or phase1.age < 0 do
        [{:age, "must be a positive number"} | errors]
      else
        errors
      end

    errors =
      if blank?(phase1.gender) or phase1.gender not in @valid_genders do
        [{:gender, "must be one of: #{Enum.join(@valid_genders, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if is_nil(phase1.totalFamilyMembers) or phase1.totalFamilyMembers < 1 do
        [{:totalFamilyMembers, "must be at least 1"} | errors]
      else
        errors
      end

    errors =
      if blank?(phase1.ayushmanCardStatus) or
           phase1.ayushmanCardStatus not in @valid_card_statuses do
        [{:ayushmanCardStatus, "must be one of: #{Enum.join(@valid_card_statuses, ", ")}"} | errors]
      else
        errors
      end

    errors =
      if phase1.ayushmanCardStatus == "Some Members Have" and
           (is_nil(phase1.ayushmanCardCount) or phase1.ayushmanCardCount < 1) do
        [{:ayushmanCardCount, "is required when status is 'Some Members Have'"} | errors]
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, phase1}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp validate_mobile_number(number, errors) when is_binary(number) do
    cleaned = String.replace(number, ~r/\D/, "")
    if String.length(cleaned) == 10 do
      errors
    else
      [{:mobileNumber, "must be exactly 10 digits"} | errors]
    end
  end

  defp validate_mobile_number(_, errors), do: [{:mobileNumber, "must be a string"} | errors]

  defp get_field(map, key), do: Map.get(map, String.to_atom(key)) || Map.get(map, key)

  defp get_field(map, snake_key, camel_key) do
    Map.get(map, String.to_atom(snake_key)) ||
      Map.get(map, snake_key) ||
      Map.get(map, String.to_atom(camel_key)) ||
      Map.get(map, camel_key)
  end

  defp get_integer(map, key) do
    case get_field(map, key) do
      nil -> nil
      val when is_integer(val) -> val
      val when is_binary(val) -> String.to_integer(val)
      _ -> nil
    end
  end

  defp get_integer(map, snake_key, camel_key) do
    case get_field(map, snake_key, camel_key) do
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
