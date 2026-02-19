defmodule RuralSurveyWeb.SurveyController do
  use RuralSurveyWeb, :controller

  alias RuralSurvey.Surveys.Survey

  @doc """
  POST /api/surveys
  Submit a new survey
  """
  def create(conn, survey_data) do
    case Survey.create_survey(survey_data, conn.assigns.current_user) do
      {:ok, survey} ->
        conn
        |> put_status(:created)
        |> json(%{
          success: true,
          survey: survey_response(survey)
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          errors: changeset_errors(changeset)
        })
    end
  end

  @doc """
  GET /api/surveys
  Get surveys for the current surveyor
  """
  def index(conn, %{"surveyor_id" => surveyor_id}) do
    surveys = Survey.get_surveys_by_surveyor(surveyor_id)

    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      surveys: Enum.map(surveys, &survey_response/1)
    })
  end

  def index(conn, _params) do
    surveys = Survey.get_surveys_by_surveyor(conn.assigns.current_user._id)

    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      surveys: Enum.map(surveys, &survey_response/1)
    })
  end

  @doc """
  GET /api/surveys/:id
  Get a specific survey
  """
  def show(conn, %{"id" => id}) do
    case Survey.get_survey(id) do
      {:ok, survey} ->
        conn
        |> put_status(:ok)
        |> json(%{
          success: true,
          survey: survey_response(survey)
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          success: false,
          errors: %{detail: "Survey not found"}
        })
    end
  end

  @doc """
  PUT /api/surveys/:id
  Update a survey
  """
  def update(conn, %{"id" => id} = params) do
    survey_data = Map.delete(params, "id")

    case Survey.update_survey(id, survey_data) do
      {:ok, survey} ->
        conn
        |> put_status(:ok)
        |> json(%{
          success: true,
          survey: survey_response(survey)
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          success: false,
          errors: %{detail: "Survey not found"}
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          success: false,
          errors: changeset_errors(changeset)
        })
    end
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

  defp changeset_errors(errors) do
    Enum.map(errors, fn {field, message} ->
      "#{field}: #{message}"
    end)
  end
end
