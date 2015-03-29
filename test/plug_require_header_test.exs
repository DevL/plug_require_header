defmodule PlugRequireHeaderTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @tag :pending
  test "block request missing the required header" do
  end

  @tag :pending
  test "allow requests having the required header set" do
  end

  @tag :pending
  test "extract the required header and assign it to the connection" do
  end
end
