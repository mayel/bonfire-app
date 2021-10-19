defmodule Bonfire.ReleaseTasks do
  import Bonfire.Me.Fake, only: [fake_user!: 1, fake_user!: 2]

  @doc """
  Creates a verified user.

      create_user("bob@example.com", "bobthehunter2", "bobby", "Bob Smith")

  The first argument is the email address of the user, second is the
  passphrase, third is the username (optional), fourth is the name of
  the user (optional).

  Optional arguments will be randomly generated if missing.

  Provide at least 2, at most 4 arguments.

  It will fail if the email address or the username is already taken.
  If only the username is taken, you'll have to login with the account
  and create the user yourself.
  """
  # TODO: struct()s should probably be replaced by
  # `Bonfire.Data.Identity.User.t/0` when available.
  @spec create_user!(String.t(), String.t()) :: struct()
  def create_user!(email, pass) do
    Application.ensure_all_started(:bonfire)
    fake_user!(new_accnt(email, pass))
  end

  @spec create_user!(String.t(), String.t(), String.t()) :: struct()
  def create_user!(email, pass, uname) do
    Application.ensure_all_started(:bonfire)
    fake_user!(new_accnt(email, pass), new_user(uname))
  end

  @spec create_user!(String.t(), String.t(), String.t(), String.t()) :: struct()
  def create_user!(email, pass, uname, name) do
    Application.ensure_all_started(:bonfire)
    fake_user!(new_accnt(email, pass), new_user(uname, name))
  end

  @doc """
  make(1) counterpart of create_user!/2, create_user!/3, create_user!/4.
  """
  @spec create_user_make!(String.t(), String.t(), String.t(), String.t()) :: struct()
  def create_user_make!(email, pass, "", ""),
    do: create_user!(email, pass)

  def create_user_make!(email, pass, uname, ""),
    do: create_user!(email, pass, uname)

  def create_user_make!(email, pass, uname, name),
    do: create_user!(email, pass, uname, name)

  @spec new_accnt(String.t(), String.t()) :: map()
  defp new_accnt(email, pass),
    do: %{email: %{email_address: email}, credential: %{password: pass}}

  @spec new_user(String.t()) :: map()
  defp new_user(uname),
    do: %{character: %{username: uname}}

  @spec new_user(String.t(), String.t()) :: map()
  defp new_user(uname, name),
    do: %{character: %{username: uname}, profile: %{name: name}}
end
