# ExNist
[![Actions Status](https://github.com/maartenvanvliet/ex_nist/workflows/elixir/badge.svg)](https://github.com/maartenvanvliet/ex_nist/actions)
[![Hex pm](http://img.shields.io/hexpm/v/ex_nist.svg?style=flat)](https://hex.pm/packages/ex_nist) [![Hex Docs](https://img.shields.io/badge/hex-docs-9768d1.svg)](https://hexdocs.pm/ex_nist) [![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
-----
Set of [Ecto.Changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html#content) functions to validate against [NIST guidelines](https://pages.nist.gov/800-63-3/sp800-63b.html#sec5).

Modeled after [laravel-nist-password-rules](https://github.com/langleyfoxall/laravel-nist-password-rules)

| Recommendation  | Implementation  |
|---|---|
| [...] at least 8 characters in length | Provided by standard Ecto.Changeset validation function |
| Passwords obtained from previous breach corpuses | The `ExNist.validate_password_breach/3` function securely checks the password against previous 3rd party data breaches, using the [Have I Been Pwned - Pwned Passwords](https://haveibeenpwned.com/Passwords) API. |
| Dictionary words | The `ExNist.validate_dictionary_words/3` rule checks the password against a list of over 102k dictionary words. |
| Context-specific words, such as the name of the service, the username | The `ExNist.validate_context_specific_words/3` rule checks the password does not contain the provided list of words. |
| Context-specific words, [...] and derivatives thereof | The `ExNist.validate_derivative_words/3` rule checks the password is not too similar to the provided list of words. |
| Repetitive or sequential characters (e.g. ‘aaaaaa’, ‘1234abcd’) | The `ExNist.validate_repetitive_chars/3` and `ExNist.validate_sequential_chars/3` rules checks if the password contains any repetitive or sequential characters. |


## Installation

The package can be installed
by adding `ex_nist` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_nist, "~> 1.0.0"},
    # Optionally add `ex_pwned`
    # {:ex_pwned, "~> 0.1.4"}
  ]
end
```

The library can use the [ExPwned](https://hex.pm/packages/ex_pwned) or you can 
implement your own client. To use `ExPwned`, add it to your `mix.exs`

## Usage

Use in a function to validate changesets.
```elixir
  def changeset(user, attrs) do
    user
    |> ExNist.validate_repetitive_chars(:password)
    |> ExNist.validate_sequential_chars(:password)
    |> ExNist.validate_context_specific_words(:password, ["name_of_app"])
    |> ExNist.validate_derivative_words(:password, ["name_of_app"])
    |> ExNist.validate_dictionary_words(:password)
    |> ExNist.validate_password_breach(:password)
  end
```

The `validation_*` functions accept an optional `:message` argument to customize
the error message.

## Docs

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_nist](https://hexdocs.pm/ex_nist).

