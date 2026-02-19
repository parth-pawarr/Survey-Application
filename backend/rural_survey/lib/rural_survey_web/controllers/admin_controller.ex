defmodule RuralSurveyWeb.AdminController do
  use RuralSurveyWeb, :controller

  alias RuralSurvey.Surveys.Survey
  alias RuralSurvey.Accounts.User

  @doc """
  GET /api/admin/dashboard/stats
  Get dashboard statistics
  """
  def dashboard_stats(conn, _params) do
    stats = Survey.get_dashboard_stats()

    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      stats: stats
    })
  end

  @doc """
  GET /api/admin/analytics
  Get survey analytics
  """
  def analytics(conn, _params) do
    analytics = Survey.get_analytics()

    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      analytics: analytics
    })
  end

  @doc """
  GET /api/admin/surveys
  Get all surveys with optional filters
  """
  def all_surveys(conn, params) do
    filters = Map.take(params, ["surveyor_id", "village_id", "status", "date_from", "date_to"])
    surveys = Survey.get_all_surveys(filters)

    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      surveys: Enum.map(surveys, &survey_response/1),
      total: length(surveys)
    })
  end

  @doc """
  GET /api/admin/surveys/export
  Export surveys in CSV format
  """
  def export_surveys(conn, %{"format" => "csv"} = params) do
    filters = Map.take(params, ["surveyor_id", "village_id", "status", "date_from", "date_to"])
    surveys = Survey.get_all_surveys(filters)

    csv_content = generate_csv(surveys)

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"surveys.csv\"")
    |> send_resp(200, csv_content)
  end

  def export_surveys(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      success: false,
      errors: %{detail: "Only CSV format is supported"}
    })
  end

  defp survey_response(survey) do
    %{
      id: BSON.ObjectId.encode!(survey._id),
      phase1: survey.phase1,
      phase2: survey.phase2,
      phase3: survey.phase3,
      phase4: survey.phase4,
      village: survey.village,
      surveyorId: survey.surveyorId,
      submittedAt: survey.submittedAt,
      createdAt: survey.createdAt,
      updatedAt: survey.updatedAt,
      status: survey.status
    }
  end

  defp generate_csv(surveys) do
    headers = [
      "ID", "Representative Name", "Mobile Number", "Age", "Gender",
      "Total Family Members", "Village", "Surveyor ID", "Submitted At"
    ]

    rows = Enum.map(surveys, fn survey ->
      [
        BSON.ObjectId.encode!(survey._id),
        get_in(survey, ["phase1", "representativeFullName"]) || "",
        get_in(survey, ["phase1", "mobileNumber"]) || "",
        get_in(survey, ["phase1", "age"]) || "",
        get_in(survey, ["phase1", "gender"]) || "",
        get_in(survey, ["phase1", "totalFamilyMembers"]) || "",
        get_in(survey, ["village", "name"]) || "",
        survey.surveyorId,
        survey.submittedAt
      ]
    end)

    # Simple CSV generation without CSV library
    csv_content = [headers | rows]
    |> Enum.map(fn row ->
      row
      |> Enum.map(&to_string/1)
      |> Enum.map(fn field -> "\"#{String.replace(field, "\"", "\"\"")}\"" end)
      |> Enum.join(",")
    end)
    |> Enum.join("\n")

    csv_content
  end
end
