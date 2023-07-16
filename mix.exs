defmodule Ecto.UUID7.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_uuid7,
      deps: deps(),
      description: "Ecto type for UUID v7",
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
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ecto, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
