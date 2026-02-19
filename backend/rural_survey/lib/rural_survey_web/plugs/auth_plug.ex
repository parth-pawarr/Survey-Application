defmodule RuralSurveyWeb.Plugs.AuthPlug do
  @moduledoc """
  Plug that validates JWT Bearer token and assigns the current user.

  Usage:

      pipeline :api do
        plug :accepts, ["json"]
      end

      pipeline :auth do
        plug RuralSurveyWeb.Plugs.AuthPlug
      end

      scope "/api", RuralSurveyWeb do
        pipe_through :api
        post "/login", AuthController, :login
      end

      scope "/api", RuralSurveyWeb do
        pipe_through [:api, :auth]
        get "/me", UserController, :me
      end

  On success, sets:
    - conn.assigns.current_user
    - conn.assigns.current_claims (raw JWT claims)

  On failure, halts with 401 and JSON body { "errors": { "detail": "Unauthorized" } }.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias RuralSurvey.Auth
  alias RuralSurveyWeb.ErrorJSON

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, token} <- extract_bearer_token(conn),
         {:ok, user} <- Auth.verify_token_and_load_user(token) do
      conn
      |> assign(:current_user, user)
      |> assign(:current_claims, %{})
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> put_view(json: ErrorJSON)
        |> put_format(:json)
        |> render(:"401")
        |> halt()
    end
  end

  defp extract_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] when byte_size(token) > 0 -> {:ok, String.trim(token)}
      _ -> {:error, :missing_token}
    end
  end
end
