defmodule FP do
  @type successful() :: any()
  @type error() :: any()
  @type monada_result() :: {:ok, successful() | {:error, error()}}
  @type m_fun() :: (any() -> monada_result())

  @spec bind(m_fun(), m_fun()) :: m_fun()
  def bind(f1, f2) do
    fn args ->
      case f1.(args) do
        {:ok, result} -> f2.(result)
        {:error, error} -> {:error, error}
      end
    end
  end

  @spec sequence([monada_result()]) :: {:ok, [successful()]} | {:error, error()}
  def sequence(result_list) do
    result_list
    |> Enum.reduce({[], nil}, fn
      {:ok, result}, {results, nil} -> {[result | results], nil}
      {:error, error}, {results, nil} -> {results, {:error, error}}
      _maybe_result, acc -> acc
    end)
    |> case do
      {results, nil} ->
        {:ok, results}

      {_, error} ->
        error
    end
  end

  def try_bind do
    func = bind(&f1/1, &f2/1) |> bind(&f3/1) |> bind(&f4/1)
    func.(7)
  end

  def f1(a) do
    {:ok, a + 1}
  end

  def f2(_a) do
    # {:ok, a + 10}
    {:error, :boom}
  end

  def f3(a) do
    {:ok, a + 100}
  end

  def f4(a) do
    {:ok, a + 1000}
  end
end
