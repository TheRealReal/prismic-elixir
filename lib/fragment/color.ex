defmodule Prismic.Fragment.Color do
  @type hexidecimal :: String.t()
  @type t :: %__MODULE__{value: hexidecimal}

  import String, only: [slice: 2, to_integer: 2]

  defmodule RGB do
    @type t :: %__MODULE__{red: String.t(), green: String.t(), blue: String.t()}

    defstruct [:red, :green, :blue]
  end

  defstruct [:value]

  def to_rgb(%{value: value}) do
    %RGB{
      red: value |> slice(0..1) |> to_integer(16),
      green: value |> slice(2..3) |> to_integer(16),
      blue: value |> slice(4..5) |> to_integer(16)
    }
  end

  def valid?(%{value: value}) do
    value =~ ~r/(\h{2})(\h{2})(\h{2})/
  end
end
