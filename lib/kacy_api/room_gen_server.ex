defmodule KacyApi.RoomGenServer do
  use GenServer

  alias KacyApi.Message

  # Callbacks

  @impl true
  def init(room_id) do
    initial_state = %{
      messages: [],
      online_users: []
    }

    Process.register(self(), String.to_atom(room_id))

    {:ok, initial_state}
  end

  @impl true
  def handle_call({:save_message, msg}, _from, state) do
    new_message_list = [msg | state |> Map.get(:messages, msg)]
    new_state = state |> Map.put(:messages, new_message_list)
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:user_join, user}, _from, state) do
    users_list = state |> Map.get(:online_users, user)

    case(Enum.find(users_list, fn u -> u == user end)) do
      nil -> new_users_list = [user | users_list]
      new_state = state |> Map.put(:online_users, new_users_list)
      {:reply, :ok, new_state}
      _ -> {:reply, :ok, state}
    end

  end

  @impl true
  def handle_call({:user_leave, user}, _from, state) do
    users_list = state |> Map.get(:online_users, user)
    new_users_list = users_list |> List.delete(user)
    new_state = state |> Map.put(:online_users, new_users_list)

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(:list_messages, _from, state) do
    {:reply, Map.get(state, :messages), state}
  end

  @impl true
  def handle_call(:list_users, _from, state) do
    {:reply, Map.get(state, :online_users), state}
  end
end
