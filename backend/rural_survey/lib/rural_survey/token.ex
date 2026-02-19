defmodule RuralSurvey.Token do
  @moduledoc """
  JWT token generation and verification.
  """
  use Joken.Config

  @impl true
  def token_config do
    default_claims()
    |> add_claim("user_id", nil, &validate_user_id/1)
    |> add_claim("username", nil, &validate_string/1)
    |> add_claim("role", nil, &validate_string/1)
  end

  defp validate_user_id(claim) when is_binary(claim), do: true
  defp validate_user_id(_), do: false

  defp validate_string(claim) when is_binary(claim), do: true
  defp validate_string(_), do: false

  @doc """
  Returns the signer for JWT (HS256) using the configured secret.
  """
  def signer do
    secret = Application.get_env(:rural_survey, __MODULE__)[:secret] || "fallback_secret"
    Joken.Signer.create("HS256", secret)
  end

  @doc """
  Generates a signed JWT with the given extra claims (e.g. user_id, username, role).
  """
  def sign_with_claims(extra_claims) when is_map(extra_claims) do
    exp_seconds = Application.get_env(:rural_survey, __MODULE__)[:default_exp_seconds] || 86_400
    exp_claim = %{"exp" => Joken.current_time() + exp_seconds}
    claims = Map.merge(extra_claims, exp_claim)
    generate_and_sign(claims, signer())
  end

  @doc """
  Verifies and validates a JWT, returning the claims.
  """
  def verify_token(token) when is_binary(token) do
    __MODULE__.verify_and_validate(token, signer())
  end
end
