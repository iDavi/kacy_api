defmodule KacyApi.MessageTest do
    use ExUnit.Case

    alias KacyApi.Message

    describe "create/1" do
      test "successfully creates a message struct with valid params" do
        params = %{authorName: "Alice", content: "Hello, world!", signature: "Nice Signature ABC123"}
        message = Message.create(params)

        assert %Message{authorName: "Alice", content: "Hello, world!", signature: "Nice Signature ABC123"} = message
      end
    end

    describe "validate/1" do
      test "returns :ok for a valid message" do
        message = %Message{authorName: "Alice", content: "Hello, world!", signature: "Nice Signature ABC123"}
        assert {:ok, ^message} = Message.validate(message)
      end

      test "returns an error when authorName is blank" do
        message = %Message{authorName: "", content: "Hello, world!", signature: "Nice Signature ABC123"}
        assert {:error, "author name can't be blank!"} = Message.validate(message)
      end

      test "returns an error when content is blank" do
        message = %Message{authorName: "Alice", content: "", signature: "Nice Signature ABC123"}
        assert {:error, "content can't be blank!"} = Message.validate(message)
      end

      test "returns an error when authorName exceeds the maximum length" do
        message = %Message{authorName: String.duplicate("A", 41), content: "Hello, world!", signature: "Nice Signature ABC123"}
        assert {:error, "author name too big!"} = Message.validate(message)
      end

      test "returns an error when content exceeds the maximum length" do
        message = %Message{authorName: "Alice", content: String.duplicate("A", 2001), signature: "Nice Signature ABC123"}
        assert {:error, "content too big!"} = Message.validate(message)
      end

      test "returns an error when signature exceeds the maximum length" do
        message = %Message{authorName: "Alice", content: "Hello, world!", signature: String.duplicate("A", 301)}
        assert {:error, "signature too big!"} = Message.validate(message)
      end
    end

    describe "fetch/2" do
      test "fetches the value of an existing key" do
        message = %Message{authorName: "Alice", content: "Hello, world!", signature: "Nice Signature ABC123"}
        assert "Alice" == Message.fetch(message, :authorName)
      end

      test "returns nil for a non-existent key" do
        message = %Message{authorName: "Alice", content: "Hello, world!", signature: "Nice Signature ABC123"}
        assert nil == Message.fetch(message, :nonexistent_key)
      end
    end

end
