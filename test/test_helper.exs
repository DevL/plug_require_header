ExUnit.start()

defmodule AppMaker do
  defmacro __using__(options) do
    quote do
      use Plug.Router
      alias Plug.Conn.Status

      plug PlugRequireHeader, unquote(options)
      plug :match
      plug :dispatch
    end
  end
end

defmodule TestApp do
  use AppMaker, headers: [api_key: "x-api-key"]

  get "/" do
    send_resp(conn, Status.code(:ok), "API key: #{conn.assigns[:api_key]}")
  end
end

defmodule TestAppWithCallback do
  use AppMaker, headers: [api_key: "x-api-key"], on_missing: {__MODULE__, :callback}

  get "/" do
    send_resp(conn, Status.code(:ok), "#{conn.assigns[:api_key]}")
  end

  def callback(conn, {_, missing_header_key}) do
    conn
    |> send_resp(Status.code(:precondition_failed), "Missing header: #{missing_header_key}")
    |> halt
  end
end

defmodule TestAppWithMultipleRequiredHeaders do
  use AppMaker, headers: [api_key: "x-api-key", secret: "x-secret"]

  get "/" do
    send_resp(conn, Status.code(:ok), "API key: #{conn.assigns[:api_key]} and the secret #{conn.assigns[:secret]}")
  end
end

defmodule TestAppWithCallbackAndMultipleRequiredHeaders do
  use AppMaker, headers: [api_key: "x-api-key", secret: "x-secret"], on_missing: {__MODULE__, :callback}

  get "/" do
    send_resp(conn, Status.code(:ok), "API key: #{conn.assigns[:api_key]} and the secret #{conn.assigns[:secret]}")
  end

  def callback(conn, {connection_key, _}) do
    conn |> assign connection_key, "is missing"
  end
end

defmodule TestAppRespondingWithJSON do
  use AppMaker, headers: [api_key: "x-api-key", secret: "x-secret"], on_missing: [status: 418, message: %{error: "I'm a teapot!"}, as: :json]

  get "/" do
    send_resp(conn, Status.code(:ok), "Never called")
  end
end

defmodule TestAppRespondingWithText do
  use AppMaker, headers: [api_key: "x-api-key", secret: "x-secret"], on_missing: [status: 418, message: "I'm a teapot!", as: :text]

  get "/" do
    send_resp(conn, Status.code(:ok), "Never called")
  end
end
