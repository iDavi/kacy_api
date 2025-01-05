defmodule KacyApiWeb.RoomChannel do
  use KacyApiWeb, :channel
  alias KacyApi.Message
  @impl true
  def join("room:" <> room_id, payload, socket) do
      cond do
        String.length(room_id) > 60 -> {:error, :error}
        true -> {:ok, socket}
      end
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
  def handle_in("message", payload, socket) do

    case Message.create(payload) |> Message.validate() do
      {:error, error_msg} -> {:reply, {:ok, %{error: error_msg}}, socket}
      {:ok, msg} ->
        broadcast(socket, "messageSent", msg)
        {:noreply, socket}
    end
  end


end
