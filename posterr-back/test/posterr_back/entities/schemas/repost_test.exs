defmodule PosterrBack.Entities.Schemas.RepostTest do
  use PosterrBack.DataCase
  alias PosterrBack.Entities.Schemas.Repost

  @valid_repost %{post_id: 1, user_id: 1}

  describe "Repost schema" do
    test "with valid params" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: true,
               errors: []
             } = Repost.changeset(%Repost{}, @valid_repost)

      assert @valid_repost == changes
    end

    test "errors on empty params" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: false,
               errors: [
                 post_id: {"can't be blank", [validation: :required]},
                 user_id: {"can't be blank", [validation: :required]}
               ]
             } = Repost.changeset(%Repost{}, %{})

      assert %{} == changes
    end
  end
end
