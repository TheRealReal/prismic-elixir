# Prismic  [![Build Status](https://travis-ci.org/TheRealReal/prismic-elixir.svg?branch=master)](https://travis-ci.org/TheRealReal/prismic-elixir)

This is an Elixir-based SDK for Prismic.io

- It is intended for use with any [Plug-based](https://github.com/elixir-plug/plug) library or framework, such as [Phoenix](https://github.com/phoenixframework/phoenix) or [Sugar](https://github.com/sugar-framework/sugar)
- The default HTTP-client is [HTTPoison](https://github.com/edgurgel/httpoison). We plan to introduce support for a configurable HTTP-client.
- We welcome other contributions as well. Please, report issues and feel free to submit pull-requests.
  - The primary authors of this library are:
    1. Coburn Berry ([coburncoburn](https://github.com/coburncoburn))
      - API
      - Cache
      - Predicates
    2. David Wu ([sudostack](https://github.com/sudostack))
      - Fragments
      - Parser
- TODOs:
  - [ ] Support authentication in the API
  - [ ] Support configurable HTTP-client

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `prismic` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prismic, "~> 0.1.0"}
  ]
end
```

set repo url in your project's config
```elixir
  config :prismic,
    repo_url: "https://micro.cdn.prismic.io/api"
```

## Usage

```elixir
Prismic.V2.API.new()
|> SearchForm.from_api()
|> SearchForm.set_ref(<ref>) # master ref / versioned ref
|> SearchForm.set_query_predicates([Predicate.at("document.id", <id>)])
|> SearchForm.submit()
|> Map.fetch!(:results)
|> Parser.parse_documents() # %Prismic.Document{id: ..., uid: ..., href: ..., fragments...}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/prismic](https://hexdocs.pm/prismic).
