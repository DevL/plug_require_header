defmodule PlugRequireHeader do
  import Plug.Conn
  alias Plug.Conn.Status

  @vsn "0.2.1"
  @doc false
  def version, do: @vsn

  @moduledoc """
  An Elixir Plug for requiring and extracting a given header.
  """

  @doc """
  Initialises the plug given a keyword list of the following format.

      [<connection_key>: <header_key>]

  * The `<connection_key>` atom is the connection key to assign the value of the header.
  * The `<header_key>` binary is the header key to be required and extracted.
  """
  def init(options) do
    headers = Keyword.fetch! options, :headers
    callback = Keyword.fetch options, :on_missing
    [List.first(headers), callback]
  end

  @doc """
  Extracts the required headers and assign them to the connection struct.
  """
  def call(conn, [{connection_key, header_key}, callback_options]) do
    callback = on_missing(callback_options)
    extract_header_key(conn, connection_key, header_key, callback)
  end

  defp on_missing(:error), do: &halt_connection/2
  defp on_missing({:ok, {module, function}}) do
    fn (conn, missing_header_key) ->
      apply module, function, [conn, missing_header_key]
    end
  end

  defp extract_header_key(conn, connection_key, header_key, callback) do
    case List.keyfind(conn.req_headers, header_key, 0) do
      {^header_key, nil} -> callback.(conn, header_key)
      {^header_key, value} -> assign_connection_key(conn, connection_key, value)
      _ -> callback.(conn, header_key)
    end
  end

  defp assign_connection_key(conn, key, value) do
    conn |> assign(key, value)
  end

  defp halt_connection(conn, _) do
    conn
    |> send_resp(Status.code(:forbidden), "")
    |> halt
  end
end
