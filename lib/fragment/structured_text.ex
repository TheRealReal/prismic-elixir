defmodule Prismic.Fragment.StructuredText do
  alias __MODULE__.Block.Text.{Heading, Image, ListItem, Paragraph, Preformatted}

  @type block :: Heading.t() | Image.t() | ListItem.t() | Paragraph.t() | Preformatted.t()
  @type t :: %__MODULE__{blocks: [block]}

  defstruct blocks: []

  @doc """
  Finds the first highest title in a structured text

  - Any title with a higher level kicks the current one out
  """
  def first_title(%__MODULE__{blocks: blocks}) do
    blocks
    |> Enum.filter(&match?(%Heading{level: level} when level <= 6, &1))
    |> Enum.min_by(& &1.level, fn -> %Heading{} end)
    |> Map.fetch!(:text)
  end
end

defimpl Prismic.Fragment, for: Prismic.Fragment.StructuredText do
  alias Prismic.Fragment.StructuredText.{Block, BlockGroup}
  alias Block.Text.ListItem

  def as_html(%{blocks: blocks}, link_resolver, html_serializer \\ nil) do
    blocks
    |> build_groups()
    |> build_html(link_resolver, html_serializer)
  end

  defp build_html(groups, link_resolver, html_serializer) do
    groups
    |> Enum.flat_map(& &1.blocks)
    |> Enum.map_join("\n\n", &Block.as_html(&1, link_resolver, html_serializer))
  end

  defp build_groups(blocks) do
    blocks
    |> Enum.group_by(&group_kind/1)
    |> Enum.map(fn {kind, blocks} ->
      %BlockGroup{kind: kind, blocks: blocks}
    end)
  end

  defp group_kind(%ListItem{ordered?: true}), do: :ol
  defp group_kind(%ListItem{ordered?: false}), do: :ul
  defp group_kind(_), do: nil
end
