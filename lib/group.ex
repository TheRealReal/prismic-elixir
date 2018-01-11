defmodule Prismic.Group do
  alias Prismic.GroupDocument

  defstruct [:group_documents]

  @type t :: %__MODULE__{group_documents: [GroupDocument.t()]}
end
