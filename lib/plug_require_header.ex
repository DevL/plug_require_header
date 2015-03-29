defmodule PlugRequireHeader do
  import Plug.Conn
  alias Plug.Conn.Status

  @vsn "0.1.0-dev"
  @doc false
  def version, do: @vsn

  def init(options) do
    options |> List.first
  end

  def call(conn, {connection_key, header_key}) do
    extract_header_key(conn, connection_key, header_key)
  end

  defp extract_header_key(conn, connection_key, header_key) do
    case List.keyfind(conn.req_headers, header_key, 0) do
      {header_key, value} -> assign_connection_key(conn, connection_key, value)
      _ -> halt_connection(conn)
    end
  end

  defp assign_connection_key(conn, key, value) do
    conn |> assign(key, value)
  end

  defp halt_connection(conn) do
    conn
    |> put_status(Status.code :forbidden)
    |> halt
  end
end
