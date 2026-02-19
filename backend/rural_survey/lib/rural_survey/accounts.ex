defmodule RuralSurvey.Accounts do
  @moduledoc """
  Accounts context for managing users.
  """

  alias RuralSurvey.Accounts.User
  alias Mongo

  @collection "users"

  @doc """
  Creates a new user in MongoDB.

  ## Examples

      iex> create_user(%{username: "john", email: "john@example.com", password_hash: "hashed_password", role: "surveyor", full_name: "John Doe"})
      {:ok, %User{}}

      iex> create_user(%{username: "john"})
      {:error, :invalid_attributes}

  """
  def create_user(attrs \\ %{}) do
    now = DateTime.utc_now()

    user_data =
      attrs
      |> Map.put(:is_active, Map.get(attrs, :is_active, true))
      |> Map.put(:created_at, now)
      |> Map.put(:updated_at, now)

    # Validate required fields
    required_fields = [:username, :email, :password_hash, :role]
    missing_fields = Enum.filter(required_fields, &(!Map.has_key?(user_data, &1)))

    if Enum.empty?(missing_fields) do
      case Mongo.insert_one(:mongo, @collection, user_data) do
        {:ok, %{inserted_id: id}} ->
          user = Map.put(user_data, :_id, id) |> User.from_map()
          {:ok, user}

        {:error, %Mongo.Error{code: 11000}} ->
          {:error, :duplicate_key}

        {:error, reason} ->
          {:error, reason}
      end
    else
      {:error, {:missing_fields, missing_fields}}
    end
  end

  @doc """
  Fetches a user by ID.

  ## Examples

      iex> get_user_by_id(id)
      {:ok, %User{}}

      iex> get_user_by_id(nonexistent_id)
      {:error, :not_found}

  """
  def get_user_by_id(id) when is_binary(id) do
    try do
      object_id = BSON.ObjectId.decode!(id)
      get_user_by_id(object_id)
    rescue
      ArgumentError -> {:error, :invalid_id}
    end
  end

  def get_user_by_id(%BSON.ObjectId{} = id) do
    case Mongo.find_one(:mongo, @collection, %{"_id" => id}) do
      nil -> {:error, :not_found}
      doc -> {:ok, User.from_map(doc)}
    end
  end

  def get_user_by_id(_), do: {:error, :invalid_id}

  @doc """
  Fetches a user by username.

  ## Examples

      iex> get_user_by_username("john")
      {:ok, %User{}}

      iex> get_user_by_username("nonexistent")
      {:error, :not_found}

  """
  def get_user_by_username(username) when is_binary(username) do
    case Mongo.find_one(:mongo, @collection, %{username: username}) do
      nil -> {:error, :not_found}
      doc -> {:ok, User.from_map(doc)}
    end
  end

  def get_user_by_username(_), do: {:error, :invalid_username}

  @doc """
  Fetches a user by email.

  ## Examples

      iex> get_user_by_email("john@example.com")
      {:ok, %User{}}

      iex> get_user_by_email("nonexistent@example.com")
      {:error, :not_found}

  """
  def get_user_by_email(email) when is_binary(email) do
    case Mongo.find_one(:mongo, @collection, %{email: email}) do
      nil -> {:error, :not_found}
      doc -> {:ok, User.from_map(doc)}
    end
  end

  def get_user_by_email(_), do: {:error, :invalid_email}

  @doc """
  Lists all users.

  ## Examples

      iex> list_users()
      [%User{}, %User{}]

  """
  def list_users do
    case Mongo.find(:mongo, @collection, %{}) do
      {:ok, cursor} ->
        cursor
        |> Enum.to_list()
        |> Enum.map(&User.from_map/1)

      {:error, _} ->
        []
    end
  end

  @doc """
  Lists active users only.

  ## Examples

      iex> list_active_users()
      [%User{}]

  """
  def list_active_users do
    case Mongo.find(:mongo, @collection, %{is_active: true}) do
      {:ok, cursor} ->
        cursor
        |> Enum.to_list()
        |> Enum.map(&User.from_map/1)

      {:error, _} ->
        []
    end
  end

  @doc """
  Updates a user in MongoDB.

  ## Examples

      iex> update_user(user, %{full_name: "Updated Name"})
      {:ok, %User{}}

      iex> update_user(user, %{})
      {:error, :no_changes}

  """
  def update_user(%User{_id: id}, attrs) when is_map(attrs) do
    if Enum.empty?(attrs) do
      {:error, :no_changes}
    else
      update_data =
        attrs
        |> Map.put(:updated_at, DateTime.utc_now())
        |> Enum.reject(fn {_k, v} -> is_nil(v) end)
        |> Map.new()

      case Mongo.update_one(:mongo, @collection, %{_id: id}, %{"$set": update_data}) do
        {:ok, _} ->
          get_user_by_id(id)

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def update_user(_, _), do: {:error, :invalid_user}
end
