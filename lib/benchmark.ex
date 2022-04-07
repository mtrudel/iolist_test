defmodule IOListTest.Benchmark do
  @chunk_size 5000

  def run do
    data = build_data()
    Process.sleep(10000)

    Benchee.run(
      %{
        "iodata_split" => fn ->
          IO.puts(iodata_split(data))
        end,
        "binary_concat" => fn ->
          IO.puts(binary_concat(data))
        end
      },
      time: 10,
      memory_time: 2
    )

    :ok
  end

  # Takes an input iolist and splits it into @chunk_size chunks, then appends
  # them back to a list
  def iodata_split(data, chunk_size \\ @chunk_size) do
    data
    |> Stream.unfold(fn data ->
      case IOListSplit.split(data, chunk_size) do
        {:error, _} ->
          nil

        {next, rest} ->
          if IO.iodata_length(next) == chunk_size do
            {next, rest}
          else
            nil
          end
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.count()
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
    |> Enum.reject(&is_nil/1)
    |> Enum.count()
  end

  # Builds approx 1GB of data as an iodata (2M avg 500 byte binaries)
  def build_data do
    Stream.repeatedly(fn -> String.duplicate("a", Enum.random(1..1000)) end)
    |> Enum.take(2_000_000)
  end
end
