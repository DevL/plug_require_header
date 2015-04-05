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

  def callback(conn, missing_header_key) do
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

  def callback(conn, "x-api-key") do
    conn |> assign :api_key, "not available"
  end

  def callback(conn, "x-secret") do
    conn |> assign :secret, "is missing"
  end
end
