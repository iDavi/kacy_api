defmodule KacyApi.UserTest do
  use ExUnit.Case

  alias KacyApi.User

  describe "create/1" do
    test "successfully creates a message struct with valid params" do
      params = %{username: "Alice", signature: "My super nice signature 123"}
      user = User.create(params)

      assert %KacyApi.User{signature: "My super nice signature 123", username: "Alice"} = user
    end
  end
end
