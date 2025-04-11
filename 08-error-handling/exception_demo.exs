defmodule ExceptionDemo do
  def try_rescue(exc_type) do
    try do
      # :a = :b
      # 42 + :a
      # raise("Somethign happend")
      # SomeModule.some(42)
      generate_exception(exc_type)
    rescue
      error in [MatchError, ArithmeticError] ->
        IO.puts("clause 1, MatchError or ArithmenicError #{inspect(error)}")

      error in [RuntimeError] ->
        IO.puts("clause 2, RuntimeError #{inspect(error)}")

      error ->
        IO.puts("clause 3, unknown error #{inspect(error)}")
    after
      IO.puts("after is always called")
    end
  end

  def try_catch(exc_type) do
    try do
      generate_exception(exc_type)
    catch
      :throw, error ->
        IO.puts("clause 1, error #{inspect(error)} type :throw")

      :error, error ->
        IO.puts("clause 2, error #{inspect(error)} type :error")

      err_type, error ->
        IO.puts("clause 3, unknown error #{inspect(error)} type #{err_type}")
    after
      IO.puts("after is always called")
    end
  end

  def generate_exception(:raise), do: raise("something happened")
  def generate_exception(:throw), do: throw("something happened")
  def generate_exception(:error), do: :erlang.error("something happened")
  def generate_exception(:exit), do: exit(:something_happened)

  def start_server() do
    GenServer.start(MyGenServer, [], name: MyGenServer)
  end

  def hello() do
    GenServer.call(MyGenServer, {:hello, 100})
  end

  def hello() do
    GenServer.call(MyGenServer, {:hello, 100})
  end

  def get_smthg() do
    try do
      GenServer.call(MyGenServer, :get_smthg)
    # rescue
    catch
      _, error ->
        IO.puts("got error #{inspect(error)}")
        {:error, :timeout}
    end
  end
end

defmodule MyGenServer do
  use GenServer  # Базовый модуль для реализации generic серверного поведения
  #   ^ макрос генерирующий дополнительный код нужный для GenServer

  @impl true
  def init(_) do  # реализует GenServer Behaviour
    state = %{}
    {:ok, state}
  end

  @impl true
  def handle_call({:hello, data}, _from, state) do # Обработчик входящий сообщений
    IO.puts("MyGenServer got message :hello with data #{inspect(data)}")
    response = 42
    {:reply, response, state}
  end

  def handle_call(:get_smthg, _from, state) do # Обработчик входящий сообщений
    IO.puts("MyGenServer got message :get_smthg")
    :timer.sleep(6000) # 6 sec, where default timeout to recive reponse is 5sec
    response = 42
    {:reply, response, state}
  end
end

