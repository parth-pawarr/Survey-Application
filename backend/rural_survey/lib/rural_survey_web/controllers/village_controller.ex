defmodule RuralSurveyWeb.VillageController do
  use RuralSurveyWeb, :controller

  alias RuralSurvey.Surveys.Village

  @doc """
  GET /api/villages
  Get all villages
  """
  def index(conn, _params) do
    villages = Village.get_all_villages()
    conn
    |> put_status(:ok)
    |> json(%{
      success: true,
      villages: Enum.map(villages, &village_response/1)
    })
  end

  defp village_response(village) do
    %{
      id: BSON.ObjectId.encode!(village._id),
      name: village.name,
      district: village.district,
      state: village.state,
      createdAt: village.createdAt
    }
  end
end
