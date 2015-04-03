defmodule PlugRequireHeaderTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Plug.Conn.Status

  @options TestApp.init([])

  test "block request missing the required header" do
    connection = conn(:get, "/")
    response = TestApp.call(connection, @options)

    assert response.status == Status.code(:forbidden)
  end

  test "block request with a header set, but without the required header" do
    connection = conn(:get, "/") |> put_req_header("x-wrong-header", "whatever")
    response = TestApp.call(connection, @options)

    assert response.status == Status.code(:forbidden)
  end

  test "extract the required header and assign it to the connection" do
    api_key = "12345"

    connection = conn(:get, "/") |> put_req_header("x-api-key", api_key)
    response = TestApp.call(connection, @options)

    assert response.status == Status.code(:ok)
    assert response.resp_body == api_key
  end

  test "extract the required header even if multiple headers are set" do
    api_key = "12345"

    connection = conn(:get, "/")
    |> put_req_header("x-api-key", api_key)
    |> put_req_header("x-wrong-header", "whatever")
    response = TestApp.call(connection, @options)

    assert response.status == Status.code(:ok)
    assert response.resp_body == api_key
  end
end
