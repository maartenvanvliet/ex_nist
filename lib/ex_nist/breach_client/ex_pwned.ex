defmodule ExNist.PasswordBreachClient.ExPwned do
  @moduledoc """
  PasswordBreachClient for haveibeenpwned.com that uses the
  `ExPwned` library.

  See https://hex.pm/packages/ex_pwned
  """
  if Code.ensure_loaded?(ExPwned) do
    @behaviour ExNist.PasswordBreachClient

    @impl true
    def password_breach_count(password) do
      ExPwned.password_breach_count(password)
    end
  else
    def password_breach_count(_password) do
      raise ArgumentError, "ExPwned dependency was not installed"
      0
    end
  end
end
