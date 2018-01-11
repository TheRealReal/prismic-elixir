defmodule Prismic.Ref do
  # TODO: have poison deal with snake case keys
  @type t :: %__MODULE__{
          id: binary,
          ref: binary,
          label: binary,
          isMasterRef: boolean,
          scheduledAt: integer | nil
        }

  defstruct [:id, :ref, :label, :scheduledAt, isMasterRef: false]
end
