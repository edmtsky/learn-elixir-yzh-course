# Protocol Demo.

# Inspect
defmodule AuthData do
  # @derive {Inspect, except: [:password]}
  defstruct [:login, :password]
    defimpl Inspect do
  end

  defimpl Inspect do
    alias Inspect.Algebra, as: A

    def inspect(data, opts) do
      A.concat(["AuthData<", A.to_doc(data.login, opts), ">"])
    end
  end

  defimpl String.Chars do
    def to_string(data) do
      "AuthData, login: ${data.login}"
    end
  end
end

defimpl String.Chars, for: Map do
  def to_string(data) do
    "Map of size: #{map_size(data)}"
  end
end
