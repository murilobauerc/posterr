defmodule PosterrBack.Repo.Migrations.AddRepostsTable do
  use Ecto.Migration

  def change do
    create table(:reposts) do
      add :post_id, references(:posts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:reposts, [:post_id])
    create index(:reposts, [:user_id])
  end
end
