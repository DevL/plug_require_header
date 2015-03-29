# PlugRequireHeader

[![Build Status](https://travis-ci.org/DevL/plug_require_header.svg?branch=master)](https://travis-ci.org/DevL/plug_require_header)
[![Inline docs](http://inch-ci.org/github/DevL/plug_require_header.svg?branch=master)](http://inch-ci.org/github/DevL/plug_require_header)
[![Hex.pm](https://img.shields.io/hexpm/v/plug_require_header.svg)](https://hex.pm/packages/plug_require_header)

An Elixir Plug for requiring and extracting a given header.

## Usage

Update your `mix.exs` file and run `mix deps.get`.
```elixir
defp deps do
  [{:plug_require_header, "~> 0.1"}]
end
```

Add the plug to e.g. a pipeline in a [Phoenix](http://www.phoenixframework.org/) controller. In this case we will require the request header `x-api-key` to be set, extract its first value and assign it the connection (a `Plug.Conn`) for later use in another plug or action.
```elixir
defmodule MyPhoenixApp.MyController do
  use MyPhoenixApp.Web, :controller
  alias Plug.Conn.Status

  plug PlugRequireHeader, api_key: "x-api-key"
  plug :action

  def index(conn, _params) do
    conn
    |> put_status Status.code(:ok)
    |> text "The API key used is: #{conn.assigns[:api_key]}"
  end
end
```
Notice how the first value required header `"x-api-key"` has been extracted and can be retrieved using `conn.assigns[:api_key]`. An alternative is to use `Plug.Conn.get_req_header/2` to get all the values associated with a given header.

By default, a missing header will return a status code of 403 (forbidden) and halt the plug pipeline, i.e. no subsequent plugs will be executed. This behaviour is to be configurable in a future version.
