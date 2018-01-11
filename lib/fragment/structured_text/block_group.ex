defmodule Prismic.Fragment.StructuredText.BlockGroup do
  @type kind :: :ol | :ul | nil
  @type blocks :: [Heading.t() | Image.t() | ListItem.t() | Paragraph.t() | Preformatted.t()]
  @type t :: %__MODULE__{kind: kind, blocks: blocks}

  defstruct [:kind, blocks: []]

  def add_block(block_group = %{blocks: blocks}, block) do
    %{block_group | blocks: [block | blocks]}
  end
end
