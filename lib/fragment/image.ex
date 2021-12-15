defmodule Prismic.Fragment.Image do
  alias Prismic.Fragment.View

  @type views :: %{String.t() => View.t()}
  @type t :: %__MODULE__{main: View.t(), views: views}

  defstruct [:main, :views]
end

defimpl Prismic.Fragment, for: Prismic.Fragment.Image do
  # TODO
  def as_html(img, _link_resolver, _html_serializer) do
    main = img.main
    %{url: url, height: h, width: w} = main
    ~s[<img src="#{url}" height="#{h}" width="#{w}" />]
  end
end
