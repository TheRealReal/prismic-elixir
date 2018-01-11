defmodule Prismic.Cache do
  @moduledoc """
  Behavior to be implemented by injectable caches
  """

  @callback get(String.t) :: any
  @callback set(String.t, any) :: any
  @callback get_or_store(String.t, any) :: any

  def cache_module do
    Application.get_env(:prismic, :cache_module) || Prismic.Cache.Default
  end

  def get(key), do: cache_module().get(key)

  def set(key, value), do: cache_module().set(key, value)

  def get_or_store(key, fun) when is_function(fun) do
    cache_module().get_or_store(key, fun)
  end
end

defmodule Prismic.Cache.Default do
  @moduledoc """
  Default cache using an agent
  """
  use Agent

  @behaviour Prismic.Cache
  defmodule Item do
    defstruct [:value, :expiration]
  end
  @ttl_seconds 60

  def start_link() do
    Agent.start_link(fn -> Map.new end, name: __MODULE__)
  end

  def get_or_store(key, fun) do
    if hit = get(key) do
      hit
    else
      case fun.() do
        {:commit, result} ->
          set(key, result)
          result
        {:ignore, result} ->
          #return function result, but don't cache failures
          result
        result ->
          set(key, result)
          result
      end
    end
  end

  def get(key) do
    Agent.get_and_update(__MODULE__, fn map ->
      now = now()
      with %Item{expiration: expiration, value: value} when expiration > now <- Map.get(map, key) do
        {value, map}
      else
        _ ->
          # if item not found, delete is noop
          # if it is expired, remove it
          {nil, Map.delete(map, key)}
      end
    end)
  end

  def set(key, value, ttl \\ @ttl_seconds) do
    Agent.update(__MODULE__, fn map ->
      Map.put(map, key, %Item{value: value, expiration: now() + ttl})
    end)
  end

  defp now, do: System.os_time(:seconds)
end
