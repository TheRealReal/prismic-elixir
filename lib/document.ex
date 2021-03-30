defmodule Prismic.Document do
  alias Prismic.{AlternateLanguage, Fragment}

  defstruct [
    :id,
    :uid,
    :type,
    :href,
    :tags,
    :slugs,
    :first_publication_date,
    :last_publication_date,
    :lang,
    :alternate_languages,
    :fragments
  ]

  @type fragment :: any()
  @type t :: %__MODULE__{
          id: String.t(),
          uid: String.t() | nil,
          type: String.t(),
          href: String.t(),
          tags: [String.t()],
          slugs: [String.t()],
          first_publication_date: DateTime.t() | nil,
          last_publication_date: DateTime.t() | nil,
          lang: String.t(),
          alternate_languages: %{optional(String.t()) => AlternateLanguage.t()},
          fragments: map
        }

  def as_html(%{fragments: fragments}, link_resolver \\ nil) do
    Enum.map(fragments, &Fragment.as_html(&1, link_resolver, nil))
  end
end
