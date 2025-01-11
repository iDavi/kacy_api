defmodule KacyApiWeb.RoomChannelTest do
  use KacyApiWeb.ChannelCase

  alias KacyApi.User

  setup do
    Process.flag(:trap_exit, true)
    {:ok, _, socket} =
      KacyApiWeb.UserSocket
      |> socket()
      |> subscribe_and_join(KacyApiWeb.RoomChannel, "room:lobby", %{
        username: "John Doe",
        signature: "Nice Signature ABC123"
      })

    %{socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push(socket, "ping", %{"hello" => "there"})
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "add user to users list when they join", %{socket: socket} do
    ref = push(socket, "list_users")

    assert_reply ref, :ok, %{
      data: [%KacyApi.User{signature: "Nice Signature ABC123", username: "John Doe"}]
    }
  end

  test "remove user from users list when they leave", %{socket: socket} do


    {:ok, _, other_socket} =
      KacyApiWeb.UserSocket
      |> socket()
      |> subscribe_and_join(KacyApiWeb.RoomChannel, "room:lobby", %{
        username: "Joanna Doe",
        signature: "Other Signature 123"
      })

    close(other_socket)
    Process.sleep(100)
    ref = push(socket, "list_users")

    assert_reply ref, :ok, %{
      data: [%KacyApi.User{signature: "Nice Signature ABC123", username: "John Doe"}]
    }
  end

  test "send a valid message to the room", %{socket: socket} do
    ref =
      push(socket, "message", %{
        authorName: "Alice",
        content: "Hello, world!",
        signature: "Nice Signature ABC123"
      })

    assert_broadcast "messageSent", %{
      authorName: "Alice",
      content: "Hello, world!",
      signature: "Nice Signature ABC123"
    }
  end

  test "send a invalid message to the room (author name in blank)", %{socket: socket} do
    ref =
      push(socket, "message", %{
        authorName: "",
        content: "Hello, world!",
        signature: "Nice Signature ABC123"
      })

    assert_reply ref, :ok, %{error: "author name can't be blank!"}
  end

  test "list messages in the room", %{socket: socket} do
    {:ok, _, other_socket} =
      KacyApiWeb.UserSocket
      |> socket()
      |> subscribe_and_join(KacyApiWeb.RoomChannel, "room:nice empty room", %{
        username: "John Doe",
        signature: "Nice Signature ABC123"
      })

    push(other_socket, "message", %{
      authorName: "Alice",
      content: "Hello, world!",
      signature: "Nice Signature ABC123"
    })


    ref = push(other_socket, "list_messages")

    close(other_socket)

    assert_reply ref, :ok, %{data: [%KacyApi.Message{authorName: "Alice", content: "Hello, world!", signature: "Nice Signature ABC123", id: _}]}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from!(socket, "broadcast", %{"some" => "data"})
    assert_push "broadcast", %{"some" => "data"}
  end


end
