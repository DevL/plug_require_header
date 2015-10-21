# PlugRequireHeader

[![Build Status](https://travis-ci.org/DevL/plug_require_header.svg?branch=master)](https://travis-ci.org/DevL/plug_require_header)
[![Inline docs](http://inch-ci.org/github/DevL/plug_require_header.svg?branch=master)](http://inch-ci.org/github/DevL/plug_require_header)
[![Hex.pm](https://img.shields.io/hexpm/v/plug_require_header.svg)](https://hex.pm/packages/plug_require_header)
[![Documentation](https://img.shields.io/badge/Documentation-online-c800c8.svg)](http://hexdocs.pm/plug_require_header)

An Elixir Plug for requiring and extracting a given header.

## Usage

Update your `mix.exs` file and run `mix deps.get`.
```elixir
defp deps do
  [{:plug_require_header, "~> 0.7"}]
end
```

Add the plug to e.g. a pipeline in a [Phoenix](http://www.phoenixframework.org/)
controller. In this case we will require the request header `x-api-key` to be set,
extract its first value and assign it the connection (a `Plug.Conn`) for later use
in another plug or action.
```elixir
defmodule MyPhoenixApp.MyController do
  use MyPhoenixApp.Web, :controller
  alias Plug.Conn.Status

  plug PlugRequireHeader, headers: [api_key: "x-api-key"]
  plug :action

  def index(conn, _params) do
    conn
    |> put_status(Status.code :ok)
    |> text "The API key used is: #{conn.assigns[:api_key]}"
  end
end
```
Notice how the first value required header `"x-api-key"` has been extracted
and can be retrieved using `conn.assigns[:api_key]`. An alternative is to use
`Plug.Conn.get_req_header/2` to get all the values associated with a given header.

By default, a missing header will return a status code of 403 (forbidden) and halt
the plug pipeline, i.e. no subsequent plugs will be executed. The same is true if
the required header is explicitly set to `nil` as the underlying HTTP server will
not include the header. This behaviour however is configurable.
```elixir
defmodule MyPhoenixApp.MyOtherController do
  use MyPhoenixApp.Web, :controller
  alias Plug.Conn.Status

  plug PlugRequireHeader, headers: [api_key: "x-api-key"],
    on_missing: [status: 418, message: %{error: "I'm a teapot!"}, as: :json]
  plug :action

  def index(conn, _params) do
    conn
    |> put_status(Status.code :ok)
    |> text "The API key used is: #{conn.assigns[:api_key]}"
  end
```
The `:on_missing` handling can be given a keyword list of options on how to handle
a missing header.

* `:status` - an `integer` or `atom` to specify the status code. If it's an atom,
it'll be looked up using the `Plug.Status.code` function. Default is `:forbidden`.
* `:message` - a `binary` sent as the response body. Default is an empty string.
* `:as` - an `atom` describing the content type and encoding. Currently supported
alternatives are `:text` for plain text and `:json` for JSON. Default is `:text`.

You can also provide a function that handles the missing header by specifying a
module/function pair in a tuple as the `:on_missing` value.
```elixir
defmodule MyPhoenixApp.MyOtherController do
  use MyPhoenixApp.Web, :controller
  alias Plug.Conn.Status

  plug PlugRequireHeader, headers: [api_key: "x-api-key"],
    on_missing: {__MODULE__, :handle_missing_header}
  plug :action

  def index(conn, _params) do
    conn
    |> put_status(Status.code :ok)
    |> text "The API key used is: #{conn.assigns[:api_key]}"
  end

  def handle_missing_header(conn, {_connection_assignment_key, missing_header_key}) do
    conn
    |> send_resp(Status.code(:bad_request), "Missing header: #{missing_header_key}")
    |> halt
  end
end
```
If the header is missing or set to `nil` the status code, a status code of 400
(bad request) will be returned before the plug pipeline is halted. Notice that
the function specified as a callback needs to be a public function as it'll be
invoked from another module. Also notice that the callback must return a `Plug.Conn` struct.

Lastly, it's possible to extract multiple headers at the same time.
```elixir
  plug PlugRequireHeader, headers: [api_key: "x-api-key", magic: "x-magic"]
```

If extracting multiple headers _and_ specifying an `:on_missing` callback, be aware
that the callback will be invoked once for each missing header. Be careful to not send
a response as you can easily run into raising a `Plug.Conn.AlreadySentError`. A way of
avoiding this is to have your callback function pattern match on the state of the `conn`.
```elixir
  plug PlugRequireHeader, headers: [api_key: "x-api-key", secret: "x-secret"],
    on_missing: {__MODULE__, :handle_missing_header}

  def handle_missing_header(%Plug.Conn{state: :sent} = conn, _), do: conn
  def handle_missing_header(conn, {_connection_assignment_key, missing_header_key}) do
    conn
    |> send_resp(Status.code(:bad_request), "Missing header: #{missing_header_key}")
    |> halt
  end
```
This example will only send a response for the first missing header.

## Online documentation

For more information, see [the full documentation](http://hexdocs.pm/plug_require_header).

## Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b I-say-we-take-off-and-nuke-it-from-orbit`)
3. Commit your changes (`git commit -am 'It is the only way to be sure!'`)
4. Push to the branch (`git push origin I-say-we-take-off-and-nuke-it-from-orbit`)
5. Create a new Pull Request
