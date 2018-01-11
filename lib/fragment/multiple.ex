defmodule Prismic.Fragment.Multiple do
  alias Prismic.Fragment

  defstruct fragments: []

  @type t :: %__MODULE__{fragments: [any()]}

  def add_fragment(%{fragments: current_fragments} = multiple, fragment) do
    fragments = [fragment | current_fragments]
    %{multiple | fragments: Enum.reverse(fragments)}
  end

  def as_html(%{fragments: fragments}, link_resolver, _) do
    Enum.map(fragments, &Fragment.as_html(&1, link_resolver))
  end
end
