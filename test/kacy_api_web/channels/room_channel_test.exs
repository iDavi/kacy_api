defmodule KacyApiWeb.RoomChannelTest do
  use KacyApiWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      KacyApiWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(KacyApiWeb.RoomChannel, "room:lobby")

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "send a valid message to the room", %{socket: socket} do
    ref =
      push(socket, "message", %{
        authorName: "Alice",
        content: "Hello, world!",
        signature: "Best regards"
      })


      assert_broadcast "messageSent", %{
        authorName: "Alice",
        content: "Hello, world!",
        signature: "Best regards"
      }
  end

  test "send a invalid message to the room (author name in blank)", %{socket: socket} do
    ref =
      push(socket, "message", %{
        authorName: "",
        content: "Hello, world!",
        signature: "Best regards"
      })


      assert_reply ref, :ok, %{error: "author name can't be blank!"}
  end


  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end
end
