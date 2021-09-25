defmodule IOListSplitTest do
  use ExUnit.Case, async: true

  describe "next_binary" do
    test "empty array" do
      assert IOListSplit.next_binary([]) == {nil, []}
    end

    test "bare binary" do
      assert IOListSplit.next_binary("a") == {"a", []}
    end

    test "single binary" do
      assert IOListSplit.next_binary(["a"]) == {"a", []}
    end

    test "nested single binary" do
      assert IOListSplit.next_binary([["a"]]) == {"a", []}
    end

    test "nested empty prefix" do
      assert IOListSplit.next_binary([[[[[], "a"]]]]) == {"a", []}
    end

    test "empty suffix" do
      assert IOListSplit.next_binary(["a", []]) == {"a", [[]]}
    end

    test "multiple binaries" do
      assert IOListSplit.next_binary(["a", "b"]) == {"a", ["b"]}
    end

    test "more complex situations" do
      assert {"a", rest} = IOListSplit.next_binary([[], [[]], [[["a"]], []], ["b", []]])
      assert {"b", _rest} = IOListSplit.next_binary(rest)
    end
  end

  describe "split" do
    test "iodata too short" do
      assert IOListSplit.split([], 1) == {:error, :length_exceeded}
    end

    test "single binary full length" do
      {head, rest} = IOListSplit.split("a", 1)
      assert IO.iodata_to_binary(head) == "a"
      assert IO.iodata_to_binary(rest) == ""
    end

    test "single binary shorter length" do
      {head, rest} = IOListSplit.split("abc", 1)
      assert IO.iodata_to_binary(head) == "a"
      assert IO.iodata_to_binary(rest) == "bc"
    end

    test "multiple binary shorter length" do
      {head, rest} = IOListSplit.split(["abc", "def"], 1)
      assert IO.iodata_to_binary(head) == "a"
      assert IO.iodata_to_binary(rest) == "bcdef"
    end

    test "multiple binary splitting length" do
      {head, rest} = IOListSplit.split(["abc", "def"], 4)
      assert IO.iodata_to_binary(head) == "abcd"
      assert IO.iodata_to_binary(rest) == "ef"
    end
  end
end
