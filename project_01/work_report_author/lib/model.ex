defmodule WorkReport.Model do
  @doc """
  Returns a list of all valid categories
  """
  def categories() do
    ["COMM", "DEV", "OPS", "DOC", "WS", "EDU"]
  end

  defmodule Task do
    @type t :: %__MODULE__{
            category: String.t(),
            description: String.t(),
            time: non_neg_integer()
          }

    @enforce_keys [:category, :description, :time]
    defstruct [:category, :description, :time]

    def new(category, description, time) do
      %__MODULE__{
        category: category,
        description: description,
        time: time
      }
    end
  end
end
