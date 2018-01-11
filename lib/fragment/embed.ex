defmodule Prismic.Fragment.Embed do
  defstruct [:embed_type, :provider, :url, :html, :o_embed_json]

  @type t :: %__MODULE__{
          embed_type: String.t(),
          provider: any(),
          url: String.t(),
          html: String.t(),
          o_embed_json: String.t()
        }
end
