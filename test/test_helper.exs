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
    send_resp(conn, Status.code(:ok), "#{conn.assigns[:api_key]}")
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
