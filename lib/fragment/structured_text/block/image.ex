defmodule Prismic.Fragment.StructuredText.Block.Image do
  alias Prismic.Fragment

  defstruct [:view, :label]

  @type t :: %__MODULE__{view: any(), label: String.t()}

  def url(%{view: %Fragment.View{url: url}}), do: url

  def width(%{view: %Fragment.View{width: width}}), do: width

  def height(%{view: %Fragment.View{height: height}}), do: height

  def alt(%{view: %Fragment.View{alt: alt}}), do: alt

  def copyright(%{view: %Fragment.View{copyright: copyright}}), do: copyright

  def link_to(%{view: %Fragment.View{link_to: link_to}}), do: link_to
end

defimpl Prismic.Fragment, for: Prismic.Fragment.StructuredText.Block.Image do
  def as_html(_, _link_resolver, _html_serializer), do: ""
end
