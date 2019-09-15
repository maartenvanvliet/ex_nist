defmodule ExNist.PasswordBreachClient.Test do
  @behaviour ExNist.PasswordBreachClient
  @moduledoc """
  Module to test with external breach detection

      BreachClient.Test.start_link({"abc", 5})

      build_changeset("abc")
      |> ExNist.validate_password_breach(:password, breach_client: BreachClient.Test)
  """

  use Agent

  def start_link({password, breach_count}) do
    Agent.start_link(fn -> {password, breach_count} end, name: __MODULE__)
  end

  def password_breach_count(password) do
    Agent.get(__MODULE__, fn {^password, breach_count} -> breach_count
    _ -> 0
    end)
  end
end
