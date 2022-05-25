defmodule HVS.Repo.Migrations.CreateVisits do
  use Ecto.Migration

  def change do
    create table(:visits) do
      add :date, :utc_datetime
      add :minutes, :integer
      add :tasks, :string
      add :member, references(:users, name: :member, on_delete: :nothing)
      add :pal, references(:users, name: :pal, on_delete: :nothing)

      timestamps()
    end

    create index(:visits, [:member])
    create index(:visits, [:pal])
  end
end
