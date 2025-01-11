defmodule KacyApiWeb.RoomChannel do
  use KacyApiWeb, :channel
  alias KacyApi.User
  alias KacyApi.RoomGenServer
  alias KacyApi.Message
  @impl true
  def join("room:" <> room_id, payload, socket) do
    if room_id |> String.to_atom() |> Process.whereis() == nil do
      GenServer.start(RoomGenServer, "ROOM_" <> room_id)
    end

    user = User.create(payload)
    socket = assign(socket, :user_info, user)

    ("ROOM_" <> room_id) |> String.to_atom() |> GenServer.call({:user_join, user})
    {:ok, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  @impl true
  def handle_in("message", payload, %{topic: "room:" <> room_id} = socket) do
    case Message.create(payload) |> Message.validate() do
      {:error, error_msg} ->
        {:reply, {:ok, %{error: error_msg}}, socket}

      {:ok, msg} ->
        ("ROOM_" <> room_id)
        |> String.to_atom()
        |> GenServer.call({:save_message, msg})

        broadcast(socket, "messageSent", msg)
        {:noreply, socket}
    end
  end

  def handle_in("list_messages", payload, %{topic: "room:" <> room_id} = socket) do
    list =
      ("ROOM_" <> room_id)
      |> String.to_atom()
      |> GenServer.call(:list_messages)

    {:reply, {:ok, %{data: list}}, socket}
  end

  def handle_in("list_users", payload, %{topic: "room:" <> room_id} = socket) do
    list =
      ("ROOM_" <> room_id)
      |> String.to_atom()
      |> GenServer.call(:list_users)

    {:reply, {:ok, %{data: list}}, socket}
  end

  @impl true
  def terminate(reason, %{topic: "room:" <> room_id} = socket) do
    ("ROOM_" <> room_id)
    |> String.to_atom()
    |> GenServer.call({:user_leave, socket.assigns.user_info})

    :ok
  end
end
