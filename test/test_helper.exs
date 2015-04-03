ExUnit.start()

defmodule TestApp do
  use Plug.Router
  alias Plug.Conn.Status

  plug PlugRequireHeader, headers: [api_key: "x-api-key"]
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, Status.code(:ok), "#{conn.assigns[:api_key]}")
  end
end

defmodule TestAppWithCallback do
  use Plug.Router
  alias Plug.Conn.Status

  plug PlugRequireHeader, headers: [api_key: "x-api-key"], on_missing: {__MODULE__, :callback}
  plug :match
  plug :dispatch

  get "/" do
    send_resp(conn, Status.code(:ok), "#{conn.assigns[:api_key]}")
  end

  def callback(conn, missing_header_key) do
    conn
    |> send_resp(Status.code(:precondition_failed), "Missing header: #{missing_header_key}")
    |> halt
  end
end
