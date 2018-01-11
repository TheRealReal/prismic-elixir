use Mix.Config

config :prismic,
  http_client_module: Prismic.HTTPClient.Echo,
  cache_module: Prismic.Cache.Echo
