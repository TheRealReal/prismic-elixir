defmodule Prismic.API do
  @moduledoc """
  Entry point for the prismic api. The overall flow is to retrieve a fresh copy of the api, select a form ( default "Everything" ), add queries, choose a ref ( default "Master" ), and submit
  """
  alias Prismic.{API, Form, Ref}

  defstruct [:repository_url, :access_token, :refs, :forms, :bookmarks]

  @type t :: %__MODULE__{
          repository_url: String.t(),
          access_token: String.t(),
          refs: [%Ref{}],
          forms: Map.t(),
          bookmarks: Map.t()
        }

  #TODO: this should take a token also
  @doc """
  Retrieve api entrypoint from a given url and authentication token
  """
  @spec new(String.t, String.t) :: {:ok, %API{}} | {:error, any}
  def new(json, repo_url) do
    case Poison.decode(json, as: %API{repository_url: repo_url, refs: [%Ref{}]}, keys: :atoms) do
      {:ok, %API{} = api} ->
        api = Map.update!(api, :forms, fn form_map ->
          for {form_name, form} <- form_map, do: {form_name, struct(Form, form)}
        end)
        {:ok, api}

      {:error, _error} = error ->
        error
    end
  end

  # TODO: this should be a function in the Ref module
  @spec find_ref(%API{}, String.t()) :: %Ref{} | nil
  def find_ref(%API{refs: refs}, label) do
    Enum.find(refs, &(&1.label == label))
  end
end
