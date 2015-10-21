defmodule PlugRequireHeader do
  import Plug.Conn
  alias Plug.Conn.Status

  @vsn "0.7.0"
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

  * a callback function with an arity of 2, specified as a tuple of
    `{module, function}`. The function will be called with the `conn` struct
    and a tuple consisting of a connection assignment key and header key pair.
    Notice that the callback may be invoked once per required header.
  * a keyword list with any or all of the following keys set.
    * `:status` - an `integer` or `atom` to specify the status code. If it's
    an atom, it'll be looked up using the `Plug.Status.code` function.
    Default is `:forbidden`.
    * `:message` - a `binary` sent as the response body.
    Default is an empty string.
    * `:as` - an `atom` describing the content type and encoding. Currently
    supported alternatives are `:text` for plain text and `:json` for JSON.
    Default is `:text`.

  If setting options instead of using a callback function, notice that the
  plug pipeline will _always_ be halted by a missing header, and the configured
  response will _only_ be sent _once_
  """
  def call(conn, options) do
    callback = on_missing(Keyword.fetch options, :on_missing)
    headers = Keyword.fetch! options, :headers
    extract_header_keys(conn, headers, callback)
  end

  defp on_missing({:ok, {module, function}}), do: use_callback(module, function)
  defp on_missing({:ok, config}) when config |> is_list, do: generate_callback(config)
  defp on_missing(_), do: generate_callback

  defp extract_header_keys(conn, [], _callback), do: conn
  defp extract_header_keys(conn, [header|remaining_headers], callback) do
    extract_header_key(conn, header, callback)
    |> extract_header_keys(remaining_headers, callback)
  end

  defp extract_header_key(conn, {connection_key, header_key}, callback) do
    case List.keyfind(conn.req_headers, header_key, 0) do
      {^header_key, value} -> assign_connection_key(conn, connection_key, value)
      _ -> callback.(conn, {connection_key, header_key})
    end
  end

  defp assign_connection_key(conn, key, value) do
    conn |> assign(key, value)
  end

  defp use_callback(module, function) do
    fn(conn, missing_key_pair) ->
      apply module, function, [conn, missing_key_pair]
    end
  end

  defp generate_callback(config \\ []) do
    status = Keyword.get config, :status, Status.code(:forbidden)
    message = Keyword.get config, :message, ""
    format = Keyword.get config, :as, :text

    fn(conn, _) ->
      if conn.halted do
        conn
      else
        conn
        |> put_resp_content_type(content_type_for format)
        |> send_resp(status, format_message(message, format))
        |> halt
      end
    end
  end

  defp content_type_for(:text), do: "text/plain"
  defp content_type_for(:json), do: "application/json"

  defp format_message(message, :text), do: message
  defp format_message(message, :json), do: Poison.encode! message
end
