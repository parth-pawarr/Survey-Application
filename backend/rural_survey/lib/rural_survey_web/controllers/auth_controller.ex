defmodule RuralSurveyWeb.AuthController do
  use RuralSurveyWeb, :controller

  alias RuralSurvey.Auth

  @doc """
  POST /api/login
  Body: %{ "username" => "...", "password" => "..." }
  Returns: %{ "token" => "jwt...", "user" => %{...} } or error.
  """
  def login(conn, %{"username" => username, "password" => password})
      when is_binary(username) and is_binary(password) do
    case Auth.sign_in(username, password) do
      {:ok, user, token} ->
        conn
        |> put_status(:ok)
        |> json(%{
          token: token,
          user: user_response(user)
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{errors: %{detail: "Invalid username or password"}})

      {:error, :user_not_found} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{errors: %{detail: "Invalid username or password"}})

      {:error, _} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{errors: %{detail: "Authentication failed"}})
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{errors: %{detail: "username and password are required"}})
  end

  defp user_response(user) do
    %{
      id: user._id && BSON.ObjectId.encode!(user._id),
      username: user.username,
      email: user.email,
      full_name: user.full_name,
      role: user.role,
      is_active: user.is_active
    }
  end
end
