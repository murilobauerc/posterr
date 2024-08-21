defmodule PosterrBack.Repo.Migrations.AddPostsTable do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :content, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:posts, [:user_id])
  end
end
