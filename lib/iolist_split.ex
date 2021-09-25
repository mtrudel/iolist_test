defmodule IOListSplit do
  @doc """
  Returns an iolist consisting of the first `length` bytes of the given list, along with the
  remainder of the iolist beyond it as a tuple. Returns `{:error, :length_exceeded}` if there are
  not `length` bytes remaining in the iolist.
  """
  def split(list, length), do: do_split([], list, length)

  defp do_split(acc, list, length) do
    case next_binary(list) do
      {nil, _} ->
        {:error, :length_exceeded}

      {head, rest} ->
        if byte_size(head) < length do
          # We still need more bytes
          do_split([acc | head], rest, length - byte_size(head))
        else
          # We have enough bytes in head
          <<head_head::binary-size(length), head_rest::binary>> = head
          {[acc | head_head], [head_rest | rest]}
        end
    end
  end

  @doc """
  Returns the next binary element of the given iolist along with the remainder of the iolist
  beyond it as a tuple. Returns `{nil, []}` if there is no other binary in the list
  """
  def next_binary(binary) when is_binary(binary), do: {binary, []}
  def next_binary([]), do: {nil, []}
  def next_binary([head]), do: next_binary(head)

  def next_binary([head | rest]) do
    case next_binary(head) do
      {nil, []} -> next_binary(rest)
      {head, []} -> {head, rest}
      {head, head_rest} -> {head, [head_rest | rest]}
    end
  end
end
