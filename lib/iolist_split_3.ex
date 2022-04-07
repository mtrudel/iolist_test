defmodule IOListSplit3 do
  @doc """
  Returns an iolist consisting of the first `length` bytes of the given list, along with the
  remainder of the iolist beyond it as a tuple. Returns `{:error, :length_exceeded}` if there are
  not `length` bytes remaining in the iolist.
  """

  @compile {:inline, split: 3}

  def split(rest, length, head \\ [], rest_rest_rest \\ []) do
    if length == 0 do
      if rest_rest_rest == [] do
        {head, rest}
      else
        {head, [rest | rest_rest_rest]}
      end
    else
      case rest do
        [rest_head | rest_rest] when rest_head != [] ->
          rest_head_length = IO.iodata_length(rest_head)

          if rest_head_length <= length do
            # We require more bytes than are in rest_head, so claim it and try again with rest_rest
            if rest_rest_rest == [] do
              split(rest_rest, length - rest_head_length, [head | rest_head])
            else
              split([rest_rest | rest_rest_rest], length - rest_head_length, [head | rest_head])
            end
          else
            # We know that we'll make up all that we need within rest_head, so split it
            if rest_rest_rest == [] do
              split(rest_head, length, head, rest_rest)
            else
              split(rest_head, length, head, [rest_rest | rest_rest_rest])
            end
          end

        <<rest_head::binary-size(length), rest_rest::binary>> ->
          if rest_rest_rest == [] do
            {[head | rest_head], rest_rest}
          else
            {[head | rest_head], [rest_rest | rest_rest_rest]}
          end

        _ ->
          {:error, :length_exceeded}
      end
    end
  end
end
