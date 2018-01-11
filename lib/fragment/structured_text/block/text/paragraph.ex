alias Prismic.Fragment.StructuredText.Block

defmodule Block.Text.Paragraph do
  @type t :: %__MODULE__{text: String.t(), spans: [Span.t()], label: String.t()}

  defstruct [:text, :label, spans: []]
end

defimpl Block, for: Block.Text.Paragraph do
  def as_html(_, _link_resolver, _html_serializer), do: ""
end
