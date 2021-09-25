defmodule IOListTest do
  @chunk_size 100
  def test do
    data = build_data()

    Benchee.run(
      %{
        "iodata_split" => fn -> iodata_split(data) end,
        "binary_concat" => fn -> binary_concat(data) end
      },
      time: 10,
      memory_time: 2
    )
  end

  # Takes an input iolist and splits it into @chunk_size chunks, then appends
  # them back to a list
  def iodata_split(data) do
    data
    |> Stream.unfold(fn data ->
      case IOListSplit.split(data, @chunk_size) do
        {:error, _} -> nil
        {next, rest} -> {next, rest}
      end
    end)
    |> Enum.reduce([], fn element, acc -> [acc | element] end)
  end

  # Takes an input iolist and splits it into @chunk_size binary chunks, then
  # concatenates them back into a large binary
  # them back to a list
  def binary_concat(data) do
    data
    |> Stream.unfold(fn data ->
      if IO.iodata_length(data) >= @chunk_size do
        <<bytes::binary-size(@chunk_size), rest::binary>> = IO.iodata_to_binary(data)
        {bytes, rest}
      else
        nil
      end
    end)
    |> Enum.reduce(<<>>, fn element, acc -> acc <> element end)
  end

  # Builds approx 1GB of data as an iodata (2M avg 500 byte binaries)
  defp build_data do
    Stream.repeatedly(fn -> String.duplicate("a", Enum.random(1..1000)) end)
    |> Enum.take(2_000_000)
  end
end
