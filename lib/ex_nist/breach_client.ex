defmodule ExNist.PasswordBreachClient do
  @moduledoc """
  Behaviour for a password breach client

  Clients should implement the password_breach_count/1 callback.
  """
  @callback password_breach_count(String.t()) :: integer
end
