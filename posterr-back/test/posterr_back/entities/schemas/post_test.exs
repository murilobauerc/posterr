defmodule PosterrBack.Entities.Schemas.PostTest do
  use PosterrBack.DataCase
  alias PosterrBack.Entities.Schemas.Post

  @valid_post %{content: "Hello, World!", user_id: 1}

  describe "Post schema" do
    test "with valid params" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: true,
               errors: []
             } = Post.changeset(%Post{}, @valid_post)

      assert @valid_post == changes
    end

    test "errors on empty params" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: false,
               errors: [
                 content: {"can't be blank", [validation: :required]},
                 user_id: {"can't be blank", [validation: :required]}
               ]
             } = Post.changeset(%Post{}, %{})

      assert %{} == changes
    end

    test "errors on content larger than 777 characters" do
      assert %Ecto.Changeset{
               changes: changes,
               valid?: false,
               errors: [
                 content:
                   {"should be at most %{count} character(s)",
                    [
                      count: 777,
                      validation: :length,
                      kind: :max,
                      type: :string
                    ]}
               ]
             } =
               Post.changeset(%Post{}, Map.put(@valid_post, :content, String.duplicate("a", 778)))

      assert Map.put(@valid_post, :content, String.duplicate("a", 778)) == changes
    end
  end
end
