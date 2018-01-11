defmodule Prismic.AlternateLanguage do
  defstruct [:id, :uid, :type, :lang]

  @type t :: %__MODULE__{id: String.t(), uid: String.t(), type: String.t(), lang: String.t()}
end
