alias Prismic.Fragment.StructuredText.Block

defmodule Block.Text.Heading do
  defstruct [:level, :text, :label, spans: []]

  @type t :: %__MODULE__{
          level: Integer.t(),
          text: String.t(),
          spans: [Span.t()],
          label: String.t()
        }
end

defimpl Block, for: Block.Text.Heading do
  # TODO
  def as_html(_heading, _link_resolver, _html_serializer), do: ""
end
