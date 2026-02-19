defmodule RuralSurvey.Accounts.User do
  @moduledoc """
  User schema for MongoDB.
  This is a struct-based schema without Ecto.
  """

  @type t :: %__MODULE__{
          _id: BSON.ObjectId.t() | nil,
          username: String.t(),
          password_hash: String.t(),
          role: String.t(),
          email: String.t(),
          full_name: String.t(),
          is_active: boolean(),
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  defstruct [
    :_id,
    :username,
    :password_hash,
    :role,
    :email,
    :full_name,
    :is_active,
    :created_at,
    :updated_at
  ]

  @doc """
  Creates a new User struct from a map (typically from MongoDB).
  """
  def from_map(map) when is_map(map) do
    %__MODULE__{
      _id: map[:_id] || map["_id"],
      username: map[:username] || map["username"],
      password_hash: map[:password_hash] || map["password_hash"],
      role: map[:role] || map["role"],
      email: map[:email] || map["email"],
      full_name: map[:full_name] || map["full_name"],
      is_active: map[:is_active] || map["is_active"] || true,
      created_at: parse_datetime(map[:created_at] || map["created_at"]),
      updated_at: parse_datetime(map[:updated_at] || map["updated_at"])
    }
  end

  @doc """
  Converts a User struct to a map suitable for MongoDB insertion.
  """
  def to_map(%__MODULE__{} = user) do
    %{
      username: user.username,
      password_hash: user.password_hash,
      role: user.role,
      email: user.email,
      full_name: user.full_name,
      is_active: user.is_active,
      created_at: user.created_at || DateTime.utc_now(),
      updated_at: user.updated_at || DateTime.utc_now()
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp parse_datetime(nil), do: nil
  defp parse_datetime(%DateTime{} = dt), do: dt
  defp parse_datetime(timestamp) when is_integer(timestamp) do
    DateTime.from_unix!(timestamp, :millisecond)
  end
  defp parse_datetime(_), do: nil
end
