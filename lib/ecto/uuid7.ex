defmodule Ecto.UUID7 do
  @moduledoc """
  A parameterized Ecto type for UUID version 7 strings.

  An extension to `Ecto.UUID`. To use the original UUID as your primary key:

  ```elixir
  defmodule Doc do
    use Ecto.Schema

    @primary_key {:uuid, :binary_id, autogenerate: true}
    schema "doc" do
      ...
    end
  end
  ```

  To use a tagged version 7 UUID:

  ```elixir
  defmodule Doc do
    use Ecto.Schema
    alias Ecto.UUID7

    schema "doc" do
      field :id, UUID7,
        primary_key: true,
        autogenerate: true,
        skip_default_validation: true,
        tag: :0xd0c
    end
  end
  ```

  """

  use Ecto.ParameterizedType
  import Bitwise, only: [band: 2]
  alias Ecto.UUID

  @type params :: %{
          optional(:seq) => [:positive | :monotonic],
          optional(:tag) => pos_integer()
        }

  @seq_opts [:positive, :monotonic]

  @impl Ecto.ParameterizedType
  @spec init(Keyword.t()) :: params
  def init(opts), do: Enum.reduce(opts, %{}, &accumulate_opts/2)

  @impl Ecto.ParameterizedType
  def autogenerate(opts, now_ms \\ &now_ms/0)

  def autogenerate(%{seq: modifiers, tag: tag}, now_ms) do
    s = modifiers |> System.unique_integer() |> band(0xFFF)
    t = now_ms.()
    <<_::48, _::4, _::12, _::2, _::12, b::50>> = :crypto.strong_rand_bytes(16)
    encode(<<t::48, 7::4, tag::12, 2::2, s::12, b::50>>)
  end

  def autogenerate(%{seq: modifiers}, now_ms) do
    s = modifiers |> System.unique_integer() |> band(0xFFF)
    t = now_ms.()
    <<_::48, _::4, a::12, _::2, _::12, b::50>> = :crypto.strong_rand_bytes(16)
    encode(<<t::48, 7::4, a::12, 2::2, s::12, b::50>>)
  end

  def autogenerate(%{tag: tag}, now_ms) do
    t = now_ms.()
    <<_::48, _::4, _::12, _::2, b::62>> = :crypto.strong_rand_bytes(16)
    encode(<<t::48, 7::4, tag::12, 2::2, b::62>>)
  end

  def autogenerate(%{}, now_ms) do
    t = now_ms.()
    <<_::48, _::4, a::12, _::2, b::62>> = :crypto.strong_rand_bytes(16)
    encode(<<t::48, 7::4, a::12, 2::2, b::62>>)
  end

  @impl Ecto.ParameterizedType
  def cast(raw_uuid, _params), do: UUID.cast(raw_uuid)

  @impl Ecto.ParameterizedType
  def dump(arg1, _dumper, _params), do: UUID.dump(arg1)

  @impl Ecto.ParameterizedType
  def load(<<_::128>> = raw_uuid, _, _), do: UUID.load(raw_uuid)
  def load(_), do: :error

  @impl Ecto.ParameterizedType
  def type(_), do: UUID.type()

  defp encode(raw_uuid) do
    case UUID.cast(raw_uuid) do
      {:ok, uuid} ->
        uuid

      _ ->
        :error
    end
  end

  # Verify options at compile time
  defp accumulate_opts({:seq, true}, acc), do: Map.put(acc, :seq, [:monotonic])
  defp accumulate_opts({:seq, [a]}, acc) when a in @seq_opts, do: Map.put(acc, :seq, [a])

  defp accumulate_opts({:seq, [a, b]}, acc) when a in @seq_opts and b in @seq_opts,
    do: Map.put(acc, :seq, [a, b])

  defp accumulate_opts({:seq = k, _}, _acc), do: raise(ArgumentError, to_string(k))

  defp accumulate_opts({:tag, tag}, acc) when is_integer(tag) and tag >= 0 and tag <= 0xFFF,
    do: Map.put(acc, :tag, tag)

  defp accumulate_opts({:tag = k, _}, _acc), do: raise(ArgumentError, to_string(k))

  # Millisecond since unix epoch
  defp now_ms, do: System.system_time(:millisecond)
end
