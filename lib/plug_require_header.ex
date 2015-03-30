defmodule PlugRequireHeader do
  import Plug.Conn
  alias Plug.Conn.Status

  @vsn "0.1.0"
  @doc false
  def version, do: @vsn

  @doc """
  Initialises the plug given a keyword list of the following format.

      [<connection_key>: <header_key>]

  * The `<connection_key>` atom is the connection key to assign the value of the header.
  * The `<header_key>` binary is the header key to be required and extracted.
  """
  def init(options) do
    options |> List.first
  end

  @doc """
  Extracts the required headers and assign them to the connection struct.
  """
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
