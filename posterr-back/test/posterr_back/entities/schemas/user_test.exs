defmodule PosterrBack.Entities.Schemas.UserTest do
  use PosterrBack.DataCase
  alias PosterrBack.Entities.Schemas.User

  @valid_user %{username: "John"}

  describe "User schema" do
    test "with valid params" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: true,
               errors: []
             } = User.changeset(%User{}, @valid_user)

      assert @valid_user == changes
    end

    test "with valid params when username is alphanumeric" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: true,
               errors: []
             } =
               User.changeset(%User{}, Map.put(@valid_user, :username, "John123"))

      assert Map.put(@valid_user, :username, "John123") == changes
    end

    test "errors on empty params" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: false,
               errors: [
                 username: {"can't be blank", [validation: :required]}
               ]
             } = User.changeset(%User{}, %{})

      assert %{} == changes
    end

    test "errors on invalid username" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: false,
               errors: [
                 username: {"has invalid format", [validation: :format]}
               ]
             } = User.changeset(%User{}, Map.put(@valid_user, :username, "!!@#"))

      assert Map.put(@valid_user, :username, "!!@#") == changes
    end
  end
end
