defmodule Ecto.UUID7.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_uuid7,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto, "~> 3.0"}
    ]
  end
end
