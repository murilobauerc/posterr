# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PosterrBack.Repo.insert!(%PosterrBack.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule Repo.Seeds do
  alias PosterrBack.Repo
  alias PosterrBack.Entities.Schemas.User
  alias Faker

  def seed() do
    Enum.each(1..4, fn _ ->
      create_user()
    end)

    IO.puts("4 users created with success.")
  end

  defp create_user do
    user_params = %{
      username: Faker.Person.first_name()
    }

    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} -> handle_insert(user)
      {:error, %Ecto.Changeset{errors: [{:username, _}]}} ->
        create_user()
      {:error, _} = error -> handle_insert(error)
    end
  end

  defp handle_insert(%User{} = user) do
    IO.puts("User created: #{user.username}")
  end

  defp handle_insert(error) do
    IO.puts("Error to create user with details: #{inspect(error)}")
  end
end

Repo.Seeds.seed()
