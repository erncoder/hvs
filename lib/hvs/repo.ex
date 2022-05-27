defmodule HVS.Repo do
  use Ecto.Repo,
    otp_app: :hvs,
    adapter: Ecto.Adapters.Postgres

  alias Ecto.Multi

  @doc """
  Upserts a list of changesets inside a transaction.
  """
  def multi_upsert(changesets) when is_list(changesets) do
    changesets
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn {changeset, index}, multi ->
      Multi.insert_or_update(multi, to_string(index), changeset)
    end)
    |> transaction()
  end
end
