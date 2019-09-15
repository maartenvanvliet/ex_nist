defmodule ExNist.MixProject do
  use Mix.Project

  @url "https://github.com/maartenvanvliet/ex_nist"
  def project do
    [
      app: :ex_nist,
      version: "1.0.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description:
        "Set of Ecto.Changeset functions to validate against NIST guidelines. (https://pages.nist.gov/800-63-3/sp800-63b.html#sec5)",
      source_url: @url,
      deps: deps(),
      docs: [extras: ["README.md"]],
      package: [
        maintainers: ["Maarten van Vliet"],
        licenses: ["MIT"],
        links: %{"GitHub" => @url},
        files: ~w(LICENSE README.md lib mix.exs static)
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.2.0"},
      {:ex_pwned, "~> 0.1.4", optional: true},
      {:credo, "~> 1.1", only: :dev},
      {:ex_doc, "~> 0.21", only: :dev}
    ]
  end
end
