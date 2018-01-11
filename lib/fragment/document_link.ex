defmodule Prismic.Fragment.DocumentLink do
  defstruct [:id, :uid, :type, :tags, :slug, :lang, :fragments, :broken, :target]

  @type fragments :: [any()]
  @type t :: %__MODULE__{
          id: String.t(),
          uid: String.t(),
          type: String.t(),
          tags: [String.t()],
          slug: String.t(),
          lang: String.t(),
          fragments: fragments,
          broken: true | false,
          target: String.t()
        }
end
