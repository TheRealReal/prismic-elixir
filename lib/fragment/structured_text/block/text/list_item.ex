alias Prismic.Fragment.StructuredText.Block

defmodule Block.Text.ListItem do
  defstruct [:ordered?, :text, :label, spans: []]

  @type t :: %__MODULE__{
          ordered?: true | false,
          text: String.t(),
          spans: [Span.t()],
          label: String.t()
        }
end

defimpl Block, for: Block.Text.ListItem do
  def as_html(_, _link_resolver, _html_serializer), do: ""
end
