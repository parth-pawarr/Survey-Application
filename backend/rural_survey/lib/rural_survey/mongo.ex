defmodule RuralSurvey.Mongo do
  @moduledoc """
  MongoDB connection supervisor.
  This module manages the MongoDB connection pool.
  """

  def start_link(_opts) do
    mongo_config = Application.get_env(:rural_survey, :mongo, [])

    name = Keyword.get(mongo_config, :name, :mongo)
    url = Keyword.get(mongo_config, :url, "mongodb://localhost:27017/rural_survey")
    pool_size = Keyword.get(mongo_config, :pool_size, 10)

    Mongo.start_link(url: url, name: name, pool_size: pool_size)
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  # Helper functions to use the MongoDB connection
  def insert_one(pool, collection, document, opts \\ []) do
    Mongo.insert_one(pool, collection, document, opts)
  end

  def find(pool, collection, filter, opts \\ []) do
    Mongo.find(pool, collection, filter, opts)
  end

  def find_one(pool, collection, filter, opts \\ []) do
    Mongo.find_one(pool, collection, filter, opts)
  end

  def update_one(pool, collection, filter, update, opts \\ []) do
    Mongo.update_one(pool, collection, filter, update, opts)
  end

  def delete_many(pool, collection, filter, opts \\ []) do
    Mongo.delete_many(pool, collection, filter, opts)
  end

  def aggregate(pool, collection, pipeline, opts \\ []) do
    Mongo.aggregate(pool, collection, pipeline, opts)
  end
end
