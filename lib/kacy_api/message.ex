defmodule KacyApi.Message do

  @derive Jason.Encoder
  defstruct [:authorName, :content, :signature]
  def create(params) when is_map(params) do
    struct(__MODULE__, %{
      authorName: params["authorName"],
      content: params["content"],
      signature: params["signature"]
    })
  end
  def validate(%__MODULE__{} = msg) do
    cond do
      String.length(msg.authorName) < 1 -> {:error, "author name can't be blank!"}
      String.length(msg.content) < 1 -> {:error, "content can't be blank!"}

      String.length(msg.authorName) > 40 -> {:error, "author name too big!"}
      String.length(msg.content) > 2000  -> {:error, "content too big!"}

      String.length(msg.signature) > 300 -> {:error, "signature too big!"}

      true -> {:ok, msg}
    end
  end
  def fetch(map, key), do: Map.get(map, key)

end
