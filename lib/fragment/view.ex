defmodule Prismic.Fragment.View do
  @type t :: %__MODULE__{
          url: String.t(),
          width: Integer.t(),
          height: Integer.t(),
          alt: String.t(),
          copyright: String.t(),
          link_to: String.t()
        }

  defstruct [:url, :width, :height, :alt, :copyright, :link_to]

  def ratio(%{width: w, height: h}), do: div(w, h)
end
