defmodule Ecto.UUID7Test do
  use ExUnit.Case, async: true
  doctest Ecto.UUID7
  alias Ecto.UUID
  alias Ecto.UUID7

  describe "init/1 with tag" do
    test "valid" do
      assert %{tag: 4078} = UUID7.init(tag: 0xFEE)
    end

    test "invalid" do
      assert_raise ArgumentError, "tag", fn ->
        UUID7.init(tag: 0xF00D)
      end
    end

    test "invalid string tag" do
      assert_raise ArgumentError, "tag", fn ->
        UUID7.init(tag: "DOC")
      end
    end

    test "invalid tag more than 12 bits" do
      assert_raise ArgumentError, "tag", fn ->
        UUID7.init(tag: 0xFFF + 1)
      end
    end
  end

  describe "init/1 with seq" do
    test "default" do
      assert %{seq: [:monotonic]} = UUID7.init(seq: true)
    end

    test "positive" do
      assert %{seq: [:positive]} = UUID7.init(seq: [:positive])
    end

    test "monotonic positive" do
      assert %{seq: [:monotonic, :positive]} = UUID7.init(seq: [:monotonic, :positive])
    end

    test "invalid arg" do
      assert_raise ArgumentError, "seq", fn ->
        UUID7.init(seq: [:strictly_decreasing])
      end
    end
  end

  describe "autogenerate/1" do
    test "hex encoding" do
      assert_uuid_matches(
        ~r/^[[:xdigit:]]{8}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/
      )
    end

    test "version 7 UUID" do
      assert_uuid_matches(
        ~r/^[[:xdigit:]]{8}-[[:xdigit:]]{4}-7[[:xdigit:]]{3}-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/
      )
    end

    test "successive not equal" do
      assert UUID7.autogenerate(%{}) != UUID7.autogenerate(%{})
    end
  end

  describe "autogenerate/1 time" do
    test "epoch" do
      assert_uuid_matches(
        now_t(0),
        %{tag: 0x000},
        ~r/^00000000-0000-7000-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/
      )
    end

    test "before epoch" do
      t = DateTime.to_unix(~U[1969-07-20 20:17:39.000Z], :millisecond)

      assert_uuid_matches(
        now_t(t),
        %{tag: 0xA11},
        ~r/^fffcb2a1-7eb8-7a11-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/
      )
    end

    test "future" do
      t = DateTime.to_unix(~U[2038-01-19 03:14:07.000Z], :millisecond)

      assert_uuid_matches(
        now_t(t),
        %{tag: 0x238},
        ~r/^01f3ffff-fc18-7238-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/
      )
    end

    test "far future" do
      t = DateTime.to_unix(~U[2138-01-19 03:14:07.000Z], :millisecond)

      assert_uuid_matches(
        now_t(t),
        %{tag: 0x075},
        ~r/^04d2bccd-cc18-7075-[[:xdigit:]]{4}-[[:xdigit:]]{12}$/
      )
    end
  end

  defp assert_uuid_matches(re) do
    uuid = %{} |> UUID7.autogenerate() |> UUID.cast!()
    assert String.match?(uuid, re)
  end

  defp assert_uuid_matches(now_ms, opt, re)
       when is_function(now_ms, 0) and
              is_map(opt) do
    uuid = opt |> UUID7.autogenerate(now_ms) |> UUID.cast!()
    assert String.match?(uuid, re)
  end

  defp now_t(t), do: fn -> t end
end
