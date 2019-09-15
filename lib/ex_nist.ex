defmodule ExNist do
  @external_resource "./README.md"
  @moduledoc """
  #{File.read!(@external_resource) |> String.split("-----", parts: 2) |> List.last()}
  """

  @doc """
  Validate a changeset field for the use of repetitive characters

  ## Examples

      iex> ExNist.validate_repetitive_chars(build_changeset("aaab"), :password)
      #Ecto.Changeset<action: nil, changes: %{password: \"aaab\"}, errors: [password: {\"This password has the same character repeated\", [validation: :repeated_character]}], data: %{}, valid?: false>

      iex> ExNist.validate_repetitive_chars(build_changeset("aab"), :password)
      #Ecto.Changeset<action: nil, changes: %{password: \"aab\"}, errors: [], data: %{}, valid?: true>
  """
  def validate_repetitive_chars(changeset, field, opts \\ []) do
    format = ~r/(.)\1{2,}/

    Ecto.Changeset.validate_change(changeset, field, {:format, format}, fn _, value ->
      if value =~ format do
        [
          {field,
           {message(opts, "This password has the same character repeated"),
            [validation: :repeated_character]}}
        ]
      else
        []
      end
    end)
  end

  @sequences ExNist.Sequence.sequences()

  @doc """
  Validate a changeset field for the use of sequences

  ## Examples

      iex> ExNist.validate_sequential_chars(build_changeset("abc"), :password)
      #Ecto.Changeset<action: nil, changes: %{password: \"abc\"}, errors: [password: {\"This password contains a sequence (e.g. abc or 123)\", []}], data: %{}, valid?: false>

      iex> ExNist.validate_sequential_chars(build_changeset("aab"), :password)
      #Ecto.Changeset<action: nil, changes: %{password: \"aab\"}, errors: [], data: %{}, valid?: true>
  """
  def validate_sequential_chars(changeset, field, opts \\ []) do
    Ecto.Changeset.validate_change(changeset, field, :validate_sequence, fn ^field, password ->
      sequences? = String.contains?(String.downcase(password), @sequences)

      case sequences? do
        false ->
          []

        true ->
          message = message(opts, "This password contains a sequence (e.g. abc or 123)")

          [{field, message}]
      end
    end)
  end

  @doc """
  Validate a changeset field for the use of context specific words. E.g. supply a list
  with words containing the username and the application name.

  ## Examples

      iex> ExNist.validate_context_specific_words(build_changeset("abc"), :password, words: ["abc"])
      #Ecto.Changeset<action: nil, changes: %{password: \"abc\"}, errors: [password: {\"This password contains disallowed words\", []}], data: %{}, valid?: false>

      iex> ExNist.validate_context_specific_words(build_changeset("aab"), :password, words: ["abc"])
      #Ecto.Changeset<action: nil, changes: %{password: \"aab\"}, errors: [], data: %{}, valid?: true>
  """
  def validate_context_specific_words(changeset, field, opts \\ []) do
    Ecto.Changeset.validate_change(changeset, field, :validate_context_specific_words, fn ^field,
                                                                                 password ->
      words = Keyword.get(opts, :words, []) |> Enum.map(fn word -> String.downcase(word) end)
      disallowed_words? = String.contains?(String.downcase(password), words)

      case disallowed_words? do
        false ->
          []

        true ->
          message = message(opts, "This password contains disallowed words")

          [{field, message}]
      end
    end)
  end

  @doc """
  Validate a changeset field for the use of derivative words of a supplied list of words. E.g. supply a list
  with words containing the username and the application name.

  ## Examples

      iex> ExNist.validate_derivative_words(build_changeset("abc"), :password, words: ["bbc"])
      #Ecto.Changeset<action: nil, changes: %{password: \"abc\"}, errors: [password: {\"This password contains derivative disallowed words\", [word: \"bbc\"]}], data: %{}, valid?: false>

      iex> ExNist.validate_derivative_words(build_changeset("abcdef"), :password, words: ["bbcdef"], similarity_percentage: 0.90)
      #Ecto.Changeset<action: nil, changes: %{password: \"abcdef\"}, errors: [], data: %{}, valid?: true>

      iex> ExNist.validate_derivative_words(build_changeset("aab"), :password, words: ["abc"])
      #Ecto.Changeset<action: nil, changes: %{password: \"aab\"}, errors: [], data: %{}, valid?: true>
  """
  def validate_derivative_words(changeset, field, opts \\ []) do
    Ecto.Changeset.validate_change(changeset, field, :validate_derivative_words, fn ^field,
                                                                                 password ->
      password = String.downcase(password)
      words = Keyword.get(opts, :words, [])
      similarity_percentage = Keyword.get(opts, :similarity_percentage, 0.75)

      similar_word =
        Enum.find(words, fn word ->

          String.jaro_distance(password, word) >= similarity_percentage
        end)

      case similar_word do
        nil ->
          []

        word ->
          message = message(opts, "This password contains derivative disallowed words")

          [{field, {message, [{:word, word}]}}]
      end
    end)
  end

  @words ExNist.Words.words()

  @doc """
  Validate a changeset field for the use of common words in a dictionary file.

  ## Examples

      iex> ExNist.validate_dictionary_words(build_changeset("Baker"), :password, words: ["bbc"])
      #Ecto.Changeset<action: nil, changes: %{password: \"Baker\"}, errors: [password: {\"This password contains disallowed words\", [word: \"baker\"]}], data: %{}, valid?: false>

      iex> ExNist.validate_dictionary_words(build_changeset("abcdef"), :password, words: ["bbcdef"])
      #Ecto.Changeset<action: nil, changes: %{password: \"abcdef\"}, errors: [], data: %{}, valid?: true>
  """
  def validate_dictionary_words(changeset, field, opts \\ []) do
    Ecto.Changeset.validate_change(changeset, field, :validate_dictionary_words, fn ^field,
                                                                                    password ->
      password = String.downcase(password)
      disallowed_word = Enum.find(@words, fn word -> password == word end)

      case disallowed_word do
        nil ->
          []

        word ->
          message = message(opts, "This password contains disallowed words")
          [{field, {message, [{:word, word}]}}]
      end
    end)
  end

  @doc """
  Validate a changeset field for the use of common words in a dictionary file.

  The `opts` accepts :password_breach_client , it defaults to ExNist.PasswordBreachClient.ExPwned
  but can be another module that implements the `ExNist.PasswordBreachClient`
  behaviour.

  ## Examples

      ExNist.validate_password_breach(build_changeset("secret"), :password)
      #Ecto.Changeset<action: nil, changes: %{password: \"Baker\"}, errors: [password: {\"This password has appeared in a data breach.\", [num_breaches: 5]}], data: %{}, valid?: false>

      ExNist.validate_password_breach(build_changeset("lkjlkjsda2dfs9234"), :password)
      #Ecto.Changeset<action: nil, changes: %{password: \"abcdef\"}, errors: [], data: %{}, valid?: true>
  """
  def validate_password_breach(changeset, field, opts \\ []) do
    Ecto.Changeset.validate_change(changeset, field, :validate_password_breach, fn ^field,
                                                                                   password ->
      breach_client = Keyword.get(opts, :breach_client, ExNist.PasswordBreachClient.ExPwned)

      case breach_client.password_breach_count(password) do
        0 ->
          []

        num_breaches ->
          message = Keyword.get(opts, :message, "This password has appeared in a data breach.")
          [{field, {message, num_breaches: num_breaches}}]
      end
    end)
  end

  defp message(opts, key \\ :message, default) do
    Keyword.get(opts, key, default)
  end
end
