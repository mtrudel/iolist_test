defmodule IOListSplit do
  @doc """
  Returns an iolist consisting of the first `length` bytes of the given list, along with the
  remainder of the iolist beyond it as a tuple. Returns `{:error, :length_exceeded}` if there are
  not `length` bytes remaining in the iolist.
  """
  def split(list, length), do: do_split([], list, length)

  # We don't need to grab any more of rest
  defp do_split(head, rest, 0), do: {head, rest}

  # All we have left is a binary, so split it if we can
  defp do_split(head, rest, length) when is_binary(rest) do
    case rest do
      <<rest_head::binary-size(length), rest_rest::binary>> ->
        {[head | rest_head], rest_rest}

      _ ->
        {:error, :length_exceeded}
    end
  end

  # We have a non-zero length still to get, but nothing left in rest
  defp do_split(_head, [], _length), do: {:error, :length_exceeded}

  defp do_split(head, [rest_head | rest_rest], length) do
    rest_head_length = IO.iodata_length(rest_head)

    if rest_head_length <= length do
      # We require more bytes than are in rest_head, so claim it and try again with rest_rest
      do_split([head | rest_head], rest_rest, length - rest_head_length)
    else
      # We know that we'll make up all that we need within rest_head, so split it
      {rest_head_head, rest_head_rest} = split(rest_head, length)
      {[head | rest_head_head], [rest_head_rest | rest_rest]}
    end
  end
end
