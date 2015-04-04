defmodule PlugRequireHeader do
  import Plug.Conn
  alias Plug.Conn.Status

  @vsn "0.3.0-dev"
  @doc false
  def version, do: @vsn

  @moduledoc """
  An Elixir Plug for requiring and extracting a given header.
  """

  @doc """
  Initialises the plug given a keyword list.
  """
  def init(options), do: options

  @doc """
  Extracts the required headers and assigns them to the connection struct.

  ## Arguments

  `conn` - the Plug.Conn connection struct
  `options` - a keyword list broken down into mandatory and optional options

  ### Mandatory options

  `:headers` - a keyword list of connection key and header key pairs.
  Each pair has the format `[<connection_key>: <header_key>]` where
  * the `<connection_key>` atom is the connection key to assign the value of
    the header.
  * the `<header_key>` binary is the header key to be required and extracted.

  ### Optional options

  `:on_missing` - specifies how to handle a missing header. It can be one of
  the following:

  * a callback function with and arity of 2, specified as a tuple of
    `{module, function}`. The function will be called with the `conn` struct
    and the missing header key. Notice that the callback may be invoked once
    per required header.
  """
  def call(conn, options) do
    callback = on_missing(Keyword.fetch options, :on_missing)
    headers = Keyword.fetch! options, :headers
    extract_header_keys(conn, headers, callback)
  end

  defp on_missing({:ok, {module, function}}) do
    fn (conn, missing_header_key) ->
      apply module, function, [conn, missing_header_key]
    end
  end
  defp on_missing(_), do: &halt_connection/2

  defp extract_header_keys(conn, [], _callback), do: conn
  defp extract_header_keys(conn, [header|remaining_headers], callback) do
    extract_header_key(conn, header, callback)
    |> extract_header_keys(remaining_headers, callback)
  end

  defp extract_header_key(conn, {connection_key, header_key}, callback) do
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
