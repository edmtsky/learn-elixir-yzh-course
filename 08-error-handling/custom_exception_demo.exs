defmodule CustomExceptionDemo do
  # request sample for happy path
  def request_1, do: %{token: "aaa", data: %{a: 42}}

  # request sample for AuthorizationError
  def request_2, do: %{token: "ccc", data: %{a: 42}}

  # request sample for AuthentificationError
  def request_3, do: %{token: "bbb", data: %{a: 42}}

  # request sample for SchemeValidationError
  def request_4, do: %{token: "aaa"}

  # request sample for Internal Server Error
  def request_5, do: %{token: "aaa", data: %{a: 100}}


  defmodule Controller do
    alias CustomExceptionDemo.Model, as: M

    # as function of our service
    def handle(request) do # представляем что это обработчик внутри контроллера
      try do
        authentificate(request)              # who you are
        authorize(request)                   # what you can access
        validate(request)
        result = do_something_useful(request)
        {200, result}
      rescue
        error in [M.AuthentificationError, M.AuthorizationError] ->
          {403, Exception.message(error)}

        error in [M.SchemeValidationError] ->
          {409, Exception.message(error)}

        error ->
          IO.puts(Exception.format(:error, error, __STACKTRACE__))  # to log
          {500, "Internal Server Error"}                            # to client
      end
    end

    # AuthN
    def authentificate(request) do
      case request.token do
        "aaa" -> :ok
        _ -> raise M.AuthentificationError, {:token, request.token}
      end
    end

    # AuthZ
    def authorize(request) do
      case request.token do
        "aaa" -> :ok
        "bbb" -> :ok
        _ -> raise M.AuthorizationError, {:guest, :reconfigure} # role + action
      end
    end

    def validate(request) do
      if Map.has_key?(request, :data) do
        :ok
      else
        raise M.SchemeValidationError, "some_schema.json"
      end
    end

    # raise RuntimeError
    def do_something_useful(%{data: %{a: 100}}), do: raise "somethign happend"

    # happy path
    def do_something_useful(%{data: %{a: a}}), do: a
  end

  # ---

  defmodule Model do
    defmodule AuthentificationError do
      # @behaviour Exception  всякое исключение должно реализовывать Exception

      @enforce_keys [:type]
      defexception [:type, :token, :login]

      @impl true
      def exception({type, data}) do  # для создания экземпляра исключения
        case type do
          # :token -> %AuthentificationError{type: :token, token: data}
          :token -> %__MODULE__{type: :token, token: data}
          :login -> %__MODULE__{type: :token, login: data}
        end
      end

      @impl true
      def message(exception) do  # для возврата текстового представления
        case exception.type do
          :token -> "AuthentificationError: invalid token"
          :login -> "AuthentificationError: invalid login"
        end
      end
    end

    defmodule AuthorizationError do
      @enforce_keys [:role, :action]
      defexception [:role, :action]

      @impl true
      def exception({role, action}) do
        %__MODULE__{role: role, action: action}
      end

      @impl true
      def message(exception) do
        "AuthorizationError: role #{exception.role} is not allowed to do"
          <> " action #{exception.action}"
      end
    end

    defmodule SchemeValidationError do
      defexception [:schema_name]

      @impl true
      def exception(schema_name) do
        %__MODULE__{schema_name: schema_name}
      end

      @impl true
      def message(exception) do
        "SchemeValidationError: data does not match schema #{exception.schema_name}"
      end
    end
  end
end

