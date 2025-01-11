defmodule KacyApi.User do
  @derive Jason.Encoder
  defstruct [:username, :signature]

  @spec create(map()) :: %__MODULE__{}
  def create(params) do
    message_map =
      params
      |> Enum.into(%{}, fn
        {key, value} when is_binary(key) -> {String.to_atom(key), value}
        {key, value} -> {key, value}
      end)
      |> Map.put(:id, UUID.uuid4())

    struct(__MODULE__, message_map)
  end

  @spec fetch(map(), String.t()) :: any()
  def fetch(map, key), do: Map.get(map, key)

end
