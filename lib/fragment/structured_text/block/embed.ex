alias Prismic.Fragment.StructuredText.Block

defmodule Block.Embed do
  alias Block.Span.Label

  defstruct [:embed, :label]

  @type t :: %__MODULE__{embed: any(), label: Label.t()}

  def embed_type(%{embed: %{embed_type: embed_type}}), do: embed_type

  def html(%{embed: %{html: html}}), do: html

  def provider(%{embed: %{provider: provider}}), do: provider

  def url(%{embed: %{url: url}}), do: url
end

defimpl Block, for: Block.Embed do
  def as_html(_, _, _), do: ""
end
