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

  test "extract the required header and assign it to the connection" do
    connection = conn(:get, "/") |> put_req_header("x-api-key", "12345")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body == "API key: 12345"
  end

  test "extract the required header even if multiple headers are set" do
    connection = conn(:get, "/")
    |> put_req_header("x-api-key", "12345")
    |> put_req_header("x-wrong-header", "whatever")
    response = TestApp.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body == "API key: 12345"
  end

  test "invoke a callback function if the required header is missing" do
    connection = conn(:get, "/")
    response = TestAppWithCallback.call(connection, [])

    assert response.status == Status.code(:precondition_failed)
    assert response.resp_body == "Missing header: x-api-key"
  end

  test "extract multiple required headers" do
    connection = conn(:get, "/")
    |> put_req_header("x-api-key", "12345")
    |> put_req_header("x-secret", "handshake")
    response = TestAppWithMultipleRequiredHeaders.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body == "API key: 12345 and the secret handshake"
  end

  test "block request missing one of several required headers" do
    connection = conn(:get, "/")
    |> put_req_header("x-api-key", "12345")
    response = TestAppWithMultipleRequiredHeaders.call(connection, [])

    assert response.status == Status.code(:forbidden)
    assert response.resp_body == ""
  end

  test "block request missing multiple required headers" do
    connection = conn(:get, "/")
    response = TestAppWithMultipleRequiredHeaders.call(connection, [])

    assert response.status == Status.code(:forbidden)
    assert response.resp_body == ""
  end

  test "invoke a callback function if any of the required headers are missing" do
    connection = conn(:get, "/")
    |> put_req_header("x-api-key", "12345")
    response = TestAppWithCallbackAndMultipleRequiredHeaders.call(connection, [])

    assert response.status == Status.code(:ok)
    assert response.resp_body == "API key: 12345 and the secret is missing"
  end

  test "respond with configured text response on missing required headers" do
    connection = conn(:get, "/")
    response = TestAppRespondingWithText.call(connection, [])

    assert response.status == 418
    assert response.resp_body == "I'm a teapot!"
  end

  test "respond with configured JSON response on missing required headers" do
    connection = conn(:get, "/")
    response = TestAppRespondingWithJSON.call(connection, [])

    assert response.status == 418
    assert response.resp_body == Poison.encode! %{error: "I'm a teapot!"}
  end
end
