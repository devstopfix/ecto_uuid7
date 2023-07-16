defmodule Ecto.UUID7.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_uuid7,
      deps: deps(),
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      package: [
        licenses: ["MIT"],
        links: %{
          "Docs" => "https://hexdocs.pm/ecto_uuid7",
          "GitHub" => "https://github.com/devstopfix/ecto_uuid7"
        }
      ],
      source_url: "https://github.com/devstopfix/ecto_uuid7",
      version: "1.0.0"
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
