defmodule KacyApi.Message do
  @derive Jason.Encoder
  defstruct [:authorName, :content, :signature]

  @spec create(map()) :: map()
  def create(params) do
    message_map =
      params
      |> Enum.into(%{}, fn
        {key, value} when is_binary(key) -> {String.to_atom(key), value}
        {key, value} -> {key, value}
      end)
    struct(__MODULE__, message_map)
  end

  @spec validate(map()) :: {:ok, map()} | {:error, String.t()}
  def validate(%__MODULE__{} = msg) do
    cond do
      String.length(msg.authorName) < 1 -> {:error, "author name can't be blank!"}
      String.length(msg.content) < 1 -> {:error, "content can't be blank!"}
      String.length(msg.authorName) > 40 -> {:error, "author name too big!"}
      String.length(msg.content) > 2000 -> {:error, "content too big!"}
      String.length(msg.signature) > 300 -> {:error, "signature too big!"}
      true -> {:ok, msg}
    end
  end

  @spec fetch(map(), String.t()) :: any()
  def fetch(map, key), do: Map.get(map, key)
end
