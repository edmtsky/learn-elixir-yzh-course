defmodule WorkReport.Model.Task do
  # - COMM - communications, working communication (meetups, mail, messenders, etc.);
  # - DEV - development and testing;
  # - OPS - operating (steaging and prod) servers;
  # - DOC - documentation (reading and writing);
  # - WS - workspace, setting up a working environment;
  # - EDU - training (yourself and others).
  @type category() :: :dev | :edu | :ops | :comm | :doc | :ws
  @type t() :: %__MODULE__{
          category: category(),
          description: String.t(),
          time: integer()
        }

  @enforce_keys [:category, :description, :time]
  defstruct [:category, :description, :time]

  @doc """
  Create a Entity of the Task model
  `[DEV] Review Pull Requests - 27m`
  """
  @spec create(category(), String.t(), integer()) :: t()
  def create(category, desc, spent_time) do
    %__MODULE__{
      category: category,
      description: desc,
      time: spent_time
    }
  end

  def new_categories_map() do
    %{
      dev: 0,
      edu: 0,
      ops: 0,
      comm: 0,
      doc: 0,
      ws: 0
    }
  end

  @doc """
  Ordered list of the categories for the formatter
  """
  def known_categories() do
    [:comm, :dev, :ops, :doc, :ws, :edu]
  end
end
