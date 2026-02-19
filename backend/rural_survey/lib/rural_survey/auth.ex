defmodule RuralSurvey.Auth do
  @moduledoc """
  JWT-based authentication for the Accounts context.
  """

  alias RuralSurvey.Accounts
  alias RuralSurvey.Accounts.User
  alias RuralSurvey.Token

  @doc """
  Authenticates a user by username and plain password.
  Returns {:ok, user, token} or {:error, reason}.

  ## Examples

      iex> sign_in("john", "password123")
      {:ok, %User{}, "eyJhbGc..."}

      iex> sign_in("john", "wrong")
      {:error, :invalid_credentials}

      iex> sign_in("unknown", "password")
      {:error, :user_not_found}
  """
  def sign_in(username, password) when is_binary(username) and is_binary(password) do
    case Accounts.get_user_by_username(username) do
      {:ok, user} ->
        if user_is_active?(user) and verify_password(password, user.password_hash) do
          case build_token(user) do
            {:ok, token} -> {:ok, user, token}
            {:error, _} -> {:error, :token_error}
          end
        else
          {:error, :invalid_credentials}
        end

      {:error, :not_found} ->
        {:error, :user_not_found}
    end
  end

  def sign_in(_, _), do: {:error, :invalid_input}

  @doc """
  Hashes a plain password for storage.
  Use this when creating users: password_hash: Auth.hash_password(plain_password)
  """
  def hash_password(plain) when is_binary(plain) do
    Pbkdf2.hash_pwd_salt(plain)
  end

  @doc """
  Generates a JWT for the given user.
  """
  def generate_token(%User{} = user) do
    build_token(user)
  end

  defp build_token(%User{} = user) do
    user_id = if user._id, do: BSON.ObjectId.encode!(user._id), else: nil
    extra_claims = %{
      "user_id" => user_id,
      "username" => user.username,
      "role" => user.role || "surveyor"
    }
    case Token.sign_with_claims(extra_claims) do
      {:ok, token, _claims} -> {:ok, token}
      {:error, _} = err -> err
    end
  end

  @doc """
  Verifies a JWT and returns the claims.
  Returns {:ok, claims} or {:error, reason}.
  """
  def verify_token(token) when is_binary(token) do
    Token.verify_token(token)
  end

  def verify_token(_), do: {:error, :invalid_token}

  @doc """
  Verifies the token and loads the current user from the database.
  Returns {:ok, user} or {:error, reason}.
  """
  def verify_token_and_load_user(token) when is_binary(token) do
    case verify_token(token) do
      {:ok, claims} ->
        user_id = claims["user_id"]
        if user_id do
          Accounts.get_user_by_id(user_id)
        else
          {:error, :invalid_claims}
        end

      {:error, _} = err ->
        err
    end
  end

  def verify_token_and_load_user(_), do: {:error, :invalid_token}

  defp user_is_active?(%User{is_active: active}) when is_boolean(active), do: active
  defp user_is_active?(_), do: true

  defp verify_password(_plain, nil), do: false
  defp verify_password(plain, hash), do: Pbkdf2.verify_pass(plain, hash)
end
