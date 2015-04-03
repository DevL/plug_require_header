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
