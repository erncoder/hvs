defmodule HVS.Visits.Visit do
  use Ecto.Schema
  import Ecto.Changeset

  schema "visits" do
    field :member, :id
    field :date, :utc_datetime
    field :minutes, :integer
    field :tasks, :string
    field :pal, :id

    timestamps()
  end

  @doc false
  def changeset(visit, attrs) do
    visit
    |> cast(attrs, [:member, :date, :minutes, :tasks, :pal])
    |> validate_required([:member, :date, :minutes, :tasks])
  end
end
