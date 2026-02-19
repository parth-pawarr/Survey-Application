defmodule RuralSurveyWeb.UserController do
  use RuralSurveyWeb, :controller

  @doc """
  GET /api/me
  Requires Authorization: Bearer <token>.
  Returns the current user (set by AuthPlug).
  """
  def me(conn, _params) do
    user = conn.assigns.current_user

    json(conn, %{
      id: user._id && BSON.ObjectId.encode!(user._id),
      username: user.username,
      email: user.email,
      full_name: user.full_name,
      role: user.role,
      is_active: user.is_active
    })
  end
end
