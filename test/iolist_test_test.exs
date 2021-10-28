defmodule IOListSplitTest do
  use ExUnit.Case, async: true

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
