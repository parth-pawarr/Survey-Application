defmodule RuralSurvey.Surveys.Village do
  @moduledoc """
  Village struct and functions for managing village data.
  """

  alias RuralSurvey.Mongo
  alias Mongo

  @type t :: %__MODULE__{
          _id: BSON.ObjectId.t() | nil,
          name: String.t(),
          district: String.t(),
          state: String.t(),
          createdAt: DateTime.t() | nil
        }

  defstruct [
    :_id,
    :name,
    :district,
    :state,
    :createdAt
  ]

  @doc """
  Gets all villages from the database
  """
  def get_all_villages do
    case Mongo.find(:mongo, "villages", %{}) do
      {:ok, cursor} ->
        cursor
        |> Enum.to_list()
        |> Enum.map(&from_map/1)

      {:error, _} ->
        []
    end
  end

  @doc """
  Creates a Village struct from a map
  """
  def from_map(map) when is_map(map) do
    %__MODULE__{
      _id: map["_id"],
      name: map["name"],
      district: map["district"],
      state: map["state"],
      createdAt: map["createdAt"]
    }
  end

  @doc """
  Seeds the database with sample villages
  """
  def seed_villages do
    villages = [
      %{
        name: "Rampur",
        district: "Bareilly",
        state: "Uttar Pradesh",
        createdAt: DateTime.utc_now()
      },
      %{
        name: "Shivpur",
        district: "Varanasi",
        state: "Uttar Pradesh",
        createdAt: DateTime.utc_now()
      },
      %{
        name: "Gopalpur",
        district: "Lucknow",
        state: "Uttar Pradesh",
        createdAt: DateTime.utc_now()
      },
      %{
        name: "Madhavpur",
        district: "Kanpur Nagar",
        state: "Uttar Pradesh",
        createdAt: DateTime.utc_now()
      },
      %{
        name: "Krishnapur",
        district: "Allahabad",
        state: "Uttar Pradesh",
        createdAt: DateTime.utc_now()
      }
    ]

    Enum.each(villages, fn village ->
      Mongo.insert_one(:mongo, "villages", village)
    end)
  end
end
