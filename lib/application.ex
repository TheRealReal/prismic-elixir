defmodule Prismic.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    cache_module = Application.get_env(:prismic, :cache_module)
    children = if is_nil(cache_module) do
      #start default cache if not provided
      [worker(Prismic.Cache.Default, [], id: :prismic_cache) ]
    else
      []
    end

    opts = [strategy: :one_for_one, name: Prismic.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
