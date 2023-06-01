defmodule Ecto.UUID7.Soak do

  @moduledoc """
  Run an extended soak test generating many IDs and checking for duplicates.

  Usage:

      mix run soak.exs 60 second

  Params are duration and unit (second, minute, hour).
  """
  alias Ecto.UUID7

  def run([duration, unit]) do
    {duration, ""} = Integer.parse(duration)
    unit = String.to_existing_atom(unit)
    finish_at = DateTime.utc_now()
    |> DateTime.add(duration, unit)
    |> DateTime.to_unix(:second)

    # UUID v7 test - choose options
    # opts = UUID7.init([])
    # opts = UUID7.init([seq: true])
    # opts = UUID7.init([tag: 0x50A])
    opts = UUID7.init([seq: true, tag: 0x50A])
    next_uuid = fn -> UUID7.autogenerate(opts) end
    # UUID v4 test
    # next_uuid = fn -> Ecto.UUID.generate() end

    start_at = now_s()
    iterate(0, start_at, start_at, finish_at, ets_new(), next_uuid)
  end

  defp iterate(n, start_at, now_s, finish_at, ets_ref, next_uuid) when now_s <= finish_at do
    uuid = next_uuid.()

    if rem(n, 1_000_000) == 0 do
      memory_bytes = ets_ref
      |> :ets.info()
      |> Keyword.fetch!(:memory)

      print(start_at, now_s, n, uuid, memory_bytes)
    end
        # true = :ets.delete(ets_ref)
        # iterate(n + 1, now_s, finish_at, ets_new)

    if :ets.insert_new(ets_ref, {uuid}) == true do
      iterate(n + 1, start_at, now_s(), finish_at, ets_ref, next_uuid)
    else
      raise "Duplicate found after #{n} iterations: #{uuid_to_string(uuid)}"
    end

  end

  defp iterate(n,_start_at, _, _, _, _) do
    IO.puts("Finished generating #{thousands(n + 1)} UUIDs")
  end

  defp print(start_at, now_s, n, uuid, memory_bytes) do
    memory_mb = to_string(Float.round(memory_bytes / 1000.0 / 1000.0 / 1000.0, 3)) <> "GB"
    rate = trunc(n / (1 + now_s-start_at) / 1000.0)
    t = now_s |> DateTime.from_unix!(:second) |> DateTime.to_iso8601()
    n = :io_lib.format("~12.16.0B", [n])
    row = [t, uuid_to_string(uuid), n, "#{rate} Kuuid/sec", memory_mb]
    IO.puts(Enum.join(row, "\t"))
  end

  defp now_s, do: System.os_time(:second)

  defp ets_new, do: :ets.new(:uuids, [:set])

  defp uuid_to_string(uuid), do: Ecto.UUID.cast!(uuid)

  defp thousands(n) do
    n
    |> Integer.digits()
    |> Enum.map(&(&1 + ?0))
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.intersperse(?,)
    |> List.flatten()
    |> Enum.reverse()
    |> to_string()
  end

end

Ecto.UUID7.Soak.run(System.argv())
