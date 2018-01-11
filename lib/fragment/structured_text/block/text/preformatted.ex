alias Prismic.Fragment.StructuredText.Block

defmodule Block.Text.Preformatted do
  defstruct [:text, :label, spans: []]

  @type t :: %__MODULE__{text: String.t(), spans: [Span.t()], label: String.t()}
end

defimpl Block, for: Block.Text.Preformatted do
  # TODO
  def as_html(_pre, _link_resolver, _html_serializer), do: ""
end
