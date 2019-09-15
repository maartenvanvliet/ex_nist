defmodule ExNistTest do
  use ExUnit.Case
  doctest ExNist
  alias ExNist.PasswordBreachClient

  defmodule User do
    defstruct [:password]
  end

  describe "validate disallowed dictionary" do
    test "validates presence of disallowed dictionary words" do
      build_changeset("aaron")
      |> ExNist.validate_dictionary_words(:password)
      |> assert_changeset_error(
        :password,
        {"This password contains disallowed words", [word: "aaron"]}
      )
    end

    test "validates presence of disallowed dictionary words with mixed case" do
      build_changeset("aArOn")
      |> ExNist.validate_dictionary_words(:password)
      |> assert_changeset_error(
        :password,
        {"This password contains disallowed words", [word: "aaron"]}
      )
    end

    test "validates absence of disallowed dictionary words" do
      build_changeset("abc")
      |> ExNist.validate_dictionary_words(:password)
      |> assert_no_changeset_error()
    end
  end

  describe "validate disallowed context words" do
    test "validates presence of disallowed words" do
      build_changeset("userljk")
      |> ExNist.validate_context_specific_words(:password, words: ["user", "email"])
      |> assert_changeset_error(
        :password,
        {"This password contains disallowed words", []}
      )
    end

    test "validates presence of disallowed words with mixed case" do
      build_changeset("usERljk")
      |> ExNist.validate_context_specific_words(:password, words: ["user", "email"])
      |> assert_changeset_error(
        :password,
        {"This password contains disallowed words", []}
      )
    end

    test "validates absence of disallowed words" do
      build_changeset("abc")
      |> ExNist.validate_context_specific_words(:password, words: ["user", "email"])
      |> assert_no_changeset_error()
    end
  end

  describe "validate disallowed derivative context words" do
    test "validates presence of derivative disallowed words" do
      build_changeset("aser")
      |> ExNist.validate_derivative_words(:password, words: ["user", "email"])
      |> assert_changeset_error(
        :password,
        {"This password contains derivative disallowed words", [word: "user"]}
      )
    end

    test "validates absence of derivative disallowed words" do
      build_changeset("abc")
      |> ExNist.validate_derivative_words(:password, words: ["user", "email"])
      |> assert_no_changeset_error()
    end
  end

  describe "validate breach detection" do
    test "validates presence of breach detection" do
      PasswordBreachClient.Test.start_link({"abc", 5})
      build_changeset("abc")
      |> ExNist.validate_password_breach(:password, breach_client: PasswordBreachClient.Test)
      |> assert_changeset_error(
        :password,
        {"This password has appeared in a data breach.", [num_breaches: 5]}
      )
    end

    test "validates absence of breach detection" do
      PasswordBreachClient.Test.start_link({"abc", 0})

      build_changeset("abc")
      |> ExNist.validate_password_breach(:password, breach_client: PasswordBreachClient.Test)
      |> assert_no_changeset_error()
    end
  end

  describe "validate string repetitions" do
    test "validates presence of repetitions" do
      build_changeset("aaablkjlkjdi")
      |> ExNist.validate_repetitive_chars(:password)
      |> assert_changeset_error(
        :password,
        {"This password has the same character repeated", [validation: :repeated_character]}
      )
    end

    test "validates absence of repetitions" do
      build_changeset("abc")
      |> ExNist.validate_repetitive_chars(:password)
      |> assert_no_changeset_error()
    end
  end

  describe "validate sequences" do
    test "validates presence of sequences" do
      build_changeset("abclkjsf098ldakjXyZ")
      |> ExNist.validate_sequential_chars(:password)
      |> assert_changeset_error(
        :password,
        {"This password contains a sequence (e.g. abc or 123)", []}
      )
    end

    test "validates presence of sequence with mixed case" do
      build_changeset("XyZ")
      |> ExNist.validate_sequential_chars(:password)
      |> assert_changeset_error(
        :password,
        {"This password contains a sequence (e.g. abc or 123)", []}
      )
    end

    test "validates absence of sequences" do
      build_changeset("abljsf09ldakj")
      |> ExNist.validate_sequential_chars(:password)
      |> assert_no_changeset_error()
    end
  end

  defp build_changeset(password) do
    data = %{}
    types = %{password: :string}
    params = %{password: password}

    {data, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end

  defp assert_no_changeset_error(changeset) do
    assert changeset.errors == []
  end

  defp assert_changeset_error(changeset, field, error) do
    assert changeset.errors != []

    assert Keyword.fetch!(changeset.errors, field) == error
  end
end
