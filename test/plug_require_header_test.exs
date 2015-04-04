defmodule PlugRequireHeaderTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Plug.Conn.Status

  test "block request missing the required header" do
    connection = conn(:get, "/")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:forbidden)
    assert response.resp_body == ""
  end

  test "block request with a header set, but without the required header" do
    connection = conn(:get, "/") |> put_req_header("x-wrong-header", "whatever")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:forbidden)
    assert response.resp_body == ""
  end

  test "block request with the required header set to nil" do
    connection = conn(:get, "/") |> put_nil_header("x-api-key")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:forbidden)
    assert response.resp_body == ""
  end

  test "extract the required header and assign it to the connection" do
    api_key = "12345"

    connection = conn(:get, "/") |> put_req_header("x-api-key", api_key)
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body == api_key
  end

  test "extract the required header even if multiple headers are set" do
    api_key = "12345"

    connection = conn(:get, "/")
    |> put_req_header("x-api-key", api_key)
    |> put_req_header("x-wrong-header", "whatever")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body == api_key
  end

  test "invoke a callback function if the required header is missing" do
    connection = conn(:get, "/")
    response = TestAppWithCallback.call(connection, [])

    assert response.status == Status.code(:precondition_failed)
    assert response.resp_body == "Missing header: x-api-key"
  end

  defp put_nil_header(%Plug.Conn{req_headers: headers} = conn, key) when is_binary(key) do
    %{conn | req_headers: :lists.keystore(key, 1, headers, {key, nil})}
  end
end
