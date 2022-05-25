defmodule HVS.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias HVS.Visits.Visit

  schema "users" do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :mins_balance, :integer

    has_many(:visits_as_member, Visit, foreign_key: :member)
    has_many(:visits_as_pal, Visit, foreign_key: :pal)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:first_name, :last_name, :email, :mins_balance])
    |> validate_required([:first_name, :last_name, :email, :mins_balance])
  end
end
