defmodule RuralSurvey.Surveys.Survey do
  @moduledoc """
  Survey struct representing a household survey with all phases.
  """

  @derive Jason.Encoder
  alias RuralSurvey.Surveys.{Phase1, Phase2, Phase3, Phase4}
  alias RuralSurvey.Mongo
  alias Mongo

  @type t :: %__MODULE__{
          _id: BSON.ObjectId.t() | nil,
          surveyorId: BSON.ObjectId.t() | nil,
          villageId: BSON.ObjectId.t() | nil,
          phase1: Phase1.t() | nil,
          phase2: Phase2.t() | nil,
          phase3: Phase3.t() | nil,
          phase4: Phase4.t() | nil,
          submittedAt: DateTime.t() | nil,
          status: String.t(),
          createdAt: DateTime.t() | nil,
          updatedAt: DateTime.t() | nil
        }

  defstruct [
    :_id,
    :surveyorId,
    :villageId,
    :phase1,
    :phase2,
    :phase3,
    :phase4,
    :submittedAt,
    :status,
    :createdAt,
    :updatedAt
  ]

  @valid_statuses ["submitted", "processing", "completed"]

  @doc """
  Creates a Survey struct from a map (typically from MongoDB or JSON).
  Handles both snake_case and camelCase keys.
  """
  def from_map(map) when is_map(map) do
    phase1 = if map["phase1"] || map[:phase1], do: Phase1.from_map(get_phase(map, "phase1")), else: nil
    phase2 = if map["phase2"] || map[:phase2], do: Phase2.from_map(get_phase(map, "phase2")), else: nil
    phase3 = if map["phase3"] || map[:phase3], do: Phase3.from_map(get_phase(map, "phase3")), else: nil
    phase4 = if map["phase4"] || map[:phase4], do: Phase4.from_map(get_phase(map, "phase4")), else: nil

    surveyor_id = parse_object_id(map, "surveyorId", "surveyor_id")
    village_id = parse_object_id(map, "villageId", "village_id")

    %__MODULE__{
      _id: parse_object_id(map, "_id", "id"),
      surveyorId: surveyor_id,
      villageId: village_id,
      phase1: phase1,
      phase2: phase2,
      phase3: phase3,
      phase4: phase4,
      submittedAt: parse_datetime(map, "submittedAt", "submitted_at"),
      status: get_field(map, "status") || "submitted",
      createdAt: parse_datetime(map, "createdAt", "created_at"),
      updatedAt: parse_datetime(map, "updatedAt", "updated_at")
    }
  end

  @doc """
  Converts Survey struct to a map suitable for MongoDB insertion.
  """
  def to_map(%__MODULE__{} = survey) do
    base = %{
      surveyorId: survey.surveyorId,
      villageId: survey.villageId,
      status: survey.status || "submitted",
      submittedAt: survey.submittedAt,
      createdAt: survey.createdAt || DateTime.utc_now(),
      updatedAt: survey.updatedAt || DateTime.utc_now()
    }

    base =
      if survey.phase1, do: Map.put(base, :phase1, Phase1.to_map(survey.phase1)), else: base

    base =
      if survey.phase2, do: Map.put(base, :phase2, Phase2.to_map(survey.phase2)), else: base

    base =
      if survey.phase3, do: Map.put(base, :phase3, Phase3.to_map(survey.phase3)), else: base

    base =
      if survey.phase4, do: Map.put(base, :phase4, Phase4.to_map(survey.phase4)), else: base

    base
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  @doc """
  Validates the entire Survey structure.
  Returns {:ok, survey} or {:error, [errors]}.
  """
  def validate(%__MODULE__{} = survey) do
    errors = []

    # Required fields
    errors =
      if is_nil(survey.surveyorId) do
        [{:surveyorId, "is required"} | errors]
      else
        errors
      end

    errors =
      if is_nil(survey.villageId) do
        [{:villageId, "is required"} | errors]
      else
        errors
      end

    errors =
      if is_nil(survey.phase1) do
        [{:phase1, "is required"} | errors]
      else
        errors
      end

    # Status validation
    errors =
      if survey.status && survey.status not in @valid_statuses do
        [{:status, "must be one of: #{Enum.join(@valid_statuses, ", ")}"} | errors]
      else
        errors
      end

    # Phase validations
    errors =
      if survey.phase1 do
        case Phase1.validate(survey.phase1) do
          {:ok, _} -> errors
          {:error, phase_errors} -> phase_errors ++ errors
        end
      else
        errors
      end

    errors =
      if survey.phase2 do
        case Phase2.validate(survey.phase2) do
          {:ok, _} -> errors
          {:error, phase_errors} -> phase_errors ++ errors
        end
      else
        errors
      end

    errors =
      if survey.phase3 do
        case Phase3.validate(survey.phase3) do
          {:ok, _} -> errors
          {:error, phase_errors} -> phase_errors ++ errors
        end
      else
        errors
      end

    errors =
      if survey.phase4 do
        case Phase4.validate(survey.phase4) do
          {:ok, _} -> errors
          {:error, phase_errors} -> phase_errors ++ errors
        end
      else
        errors
      end

    if Enum.empty?(errors) do
      {:ok, survey}
    else
      {:error, Enum.reverse(errors)}
    end
  end

  defp get_phase(map, key) do
    Map.get(map, String.to_atom(key)) || Map.get(map, key)
  end

  defp get_field(map, key) do
    Map.get(map, String.to_atom(key)) || Map.get(map, key)
  end

  defp get_field(map, camel_key, snake_key) do
    Map.get(map, String.to_atom(camel_key)) ||
      Map.get(map, camel_key) ||
      Map.get(map, String.to_atom(snake_key)) ||
      Map.get(map, snake_key)
  end

  defp parse_object_id(map, camel_key, snake_key) do
    case get_field(map, camel_key, snake_key) do
      nil -> nil
      %BSON.ObjectId{} = id -> id
      id when is_binary(id) ->
        try do
          BSON.ObjectId.decode!(id)
        rescue
          ArgumentError -> nil
        end
      _ -> nil
    end
  end

  defp parse_datetime(map, camel_key, snake_key) do
    case get_field(map, camel_key, snake_key) do
      nil -> nil
      %DateTime{} = dt -> dt
      timestamp when is_integer(timestamp) -> DateTime.from_unix!(timestamp, :millisecond)
      _ -> nil
    end
  end

  @doc """
  Creates a new survey in the database
  """
  def create_survey(survey_data, current_user) do
    survey_map = Map.merge(survey_data, %{
      "surveyorId" => current_user._id,
      "submittedAt" => DateTime.utc_now(),
      "status" => "submitted",
      "createdAt" => DateTime.utc_now(),
      "updatedAt" => DateTime.utc_now()
    })

    survey = from_map(survey_map)

    case validate(survey) do
      {:ok, valid_survey} ->
        case Mongo.insert_one(:mongo, "surveys", to_map(valid_survey)) do
          {:ok, result} ->
            survey_with_id = %{valid_survey | _id: result.inserted_id}
            {:ok, survey_with_id}

          {:error, error} ->
            {:error, "Database error: #{inspect(error)}"}
        end

      {:error, errors} ->
        {:error, errors}
    end
  end

  @doc """
  Gets surveys by surveyor ID
  """
  def get_surveys_by_surveyor(surveyor_id) do
    surveyor_oid = if is_binary(surveyor_id), do: BSON.ObjectId.decode!(surveyor_id), else: surveyor_id

    case Mongo.find(:mongo, "surveys", %{"surveyorId" => surveyor_oid}) do
      {:ok, cursor} ->
        surveys = cursor |> Enum.to_list() |> Enum.map(&from_map/1)
        {:ok, surveys}

      {:error, error} ->
        {:error, "Database error: #{inspect(error)}"}
    end
  end

  @doc """
  Gets a survey by ID
  """
  def get_survey(survey_id) do
    survey_oid = if is_binary(survey_id), do: BSON.ObjectId.decode!(survey_id), else: survey_id

    case Mongo.find_one(:mongo, "surveys", %{"_id" => survey_oid}) do
      {:ok, survey} when not is_nil(survey) ->
        {:ok, from_map(survey)}

      {:ok, nil} ->
        {:error, :not_found}

      {:error, error} ->
        {:error, "Database error: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a survey
  """
  def update_survey(survey_id, survey_data) do
    survey_oid = if is_binary(survey_id), do: BSON.ObjectId.decode!(survey_id), else: survey_id

    updated_data = Map.merge(survey_data, %{
      "updatedAt" => DateTime.utc_now()
    })

    case Mongo.update_one(:mongo, "surveys", %{"_id" => survey_oid}, %{"$set" => updated_data}) do
      {:ok, result} when result.modified_count > 0 ->
        get_survey(survey_id)

      {:ok, _} ->
        {:error, :not_found}

      {:error, error} ->
        {:error, "Database error: #{inspect(error)}"}
    end
  end

  @doc """
  Gets all surveys with optional filters
  """
  def get_all_surveys(filters \\ %{}) do
    query = build_filters_query(filters)

    case Mongo.find(:mongo, "surveys", query) do
      {:ok, cursor} ->
        surveys = cursor |> Enum.to_list() |> Enum.map(&from_map/1)
        surveys

      {:error, _error} ->
        []
    end
  end

  @doc """
  Gets dashboard statistics
  """
  def get_dashboard_stats do
    case Mongo.aggregate(:mongo, "surveys", [
      %{"$group" => %{
        "_id" => nil,
        "total_surveys" => %{"$sum" => 1},
        "submitted_surveys" => %{"$sum" => %{"$cond" => [%{"$eq" => ["$status", "submitted"]}, 1, 0]}},
        "processing_surveys" => %{"$sum" => %{"$cond" => [%{"$eq" => ["$status", "processing"]}, 1, 0]}},
        "completed_surveys" => %{"$sum" => %{"$cond" => [%{"$eq" => ["$status", "completed"]}, 1, 0]}}
      }}
    ]) do
      {:ok, [stats | _]} when not is_nil(stats) ->
        Map.delete(stats, "_id")

      {:ok, []} ->
        %{total_surveys: 0, submitted_surveys: 0, processing_surveys: 0, completed_surveys: 0}

      {:error, _error} ->
        %{total_surveys: 0, submitted_surveys: 0, processing_surveys: 0, completed_surveys: 0}
    end
  end

  @doc """
  Gets survey analytics for charts
  """
  def get_analytics do
    health_analytics = get_health_analytics()
    employment_analytics = get_employment_analytics()

    %{
      health_issues: health_analytics,
      employment_types: employment_analytics
    }
  end

  defp get_health_analytics do
    case Mongo.aggregate(:mongo, "surveys", [
      %{"$unwind" => "$phase2.affectedMembers"},
      %{"$group" => %{
        "_id" => "$phase2.affectedMembers.healthIssueType",
        "count" => %{"$sum" => 1}
      }},
      %{"$sort" => %{"count" => -1}}
    ]) do
      {:ok, results} ->
        Enum.map(results, fn item ->
          %{
            issue: item["_id"] || "Other",
            count: item["count"]
          }
        end)

      {:error, _error} ->
        []
    end
  end

  defp get_employment_analytics do
    case Mongo.aggregate(:mongo, "surveys", [
      %{"$unwind" => "$phase4.employedMembers"},
      %{"$group" => %{
        "_id" => "$phase4.employedMembers.employmentType",
        "count" => %{"$sum" => 1}
      }},
      %{"$sort" => %{"count" => -1}}
    ]) do
      {:ok, results} ->
        Enum.map(results, fn item ->
          %{
            type: item["_id"] || "Other",
            count: item["count"]
          }
        end)

      {:error, _error} ->
        []
    end
  end

  defp build_filters_query(filters) do
    Enum.reduce(filters, %{}, fn {key, value}, acc ->
      case key do
        "surveyor_id" ->
          surveyor_oid = BSON.ObjectId.decode!(value)
          Map.put(acc, "surveyorId", surveyor_oid)

        "village_id" ->
          village_oid = BSON.ObjectId.decode!(value)
          Map.put(acc, "villageId", village_oid)

        "status" ->
          Map.put(acc, "status", value)

        "date_from" ->
          date_from = DateTime.from_iso8601(value <> "T00:00:00Z") |> elem(1) |> DateTime.to_unix()
          Map.update(acc, "submittedAt", %{"$gte" => date_from}, &Map.put(&1, "$gte", date_from))

        "date_to" ->
          date_to = DateTime.from_iso8601(value <> "T23:59:59Z") |> elem(1) |> DateTime.to_unix()
          Map.update(acc, "submittedAt", %{"$lte" => date_to}, &Map.put(&1, "$lte", date_to))

        _ ->
          acc
      end
    end)
  end
end
