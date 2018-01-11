defmodule Prismic.Fragment.Geopoint do
  @type t :: %__MODULE__{latitude: String.t(), longitude: String.t()}

  defstruct [:latitude, :longitude]
end
