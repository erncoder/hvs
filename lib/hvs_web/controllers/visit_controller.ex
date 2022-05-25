defmodule HVSWeb.VisitController do
  @moduledoc """
  Controller for Visit-related routes.
  """
  use HVSWeb, :controller

  @compile if Mix.env() == :test, do: :export_all

  alias Ecto.Multi

  alias HVS.{
    Repo,
    Users,
    Users.User,
    Visits,
    Visits.Visit
  }

  require Logger

  def create_visit(conn, params) do
    # add check for minutes to confirm has enough
    case Visits.create_visit(params) do
      {:ok, _visit} ->
        conn |> put_status(201)

      resp ->
        Logger.error("failed to create visit with resp <<< #{inspect(resp)} >>>")
        conn |> put_status(500)
    end
  end

  @doc """
  Transfers minutes from a member to a pal and updates the appropriate visit
  with the pal's id.

  ## Examples

    iex> fulfill_visit()
  """

  def fulfill_visit(conn, %{"pal_id" => pal_id, "visit_id" => visit_id}) do
    visit = %Visit{member: member_id, minutes: mins} = Visits.get_visit!(visit_id)
    visit_cs = Visits.change_visit(visit, %{pal: pal_id})

    member = %User{mins_balance: m_balance} = member_id |> Users.get_user!()
    member_cs = Users.change_user(member, %{mins_balance: new_balance(m_balance, mins, :deduct)})

    pal = %User{mins_balance: pal_balance} = pal_id |> Users.get_user!()
    pal_cs = Users.change_user(pal, %{mins_balance: new_balance(pal_balance, mins, :add)})

    changesets = [member_cs, pal_cs, visit_cs]

    with {:valid?, true} <- {:valid?, Enum.all?(changesets, fn cs -> cs.valid? end)},
         {:insert, :ok} <- {:insert, multi_upsert(changesets)} do
      conn |> put_status(201)
    else
      {stage, resp} ->
        Logger.error(
          "`fulfill_visit` fail on stage #{inspect(stage)} with resp <<< #{inspect(resp)} >>>"
        )

        conn |> put_status(500)
    end
  end

  def fulfill_visit(conn, _params), do: conn |> put_status(400)

  defp multi_upsert(changesets) do
    changesets
    |> Enum.with_index()
    |> Enum.reduce(Multi.new(), fn {changeset, index}, multi ->
      Multi.insert_or_update(multi, to_string(index), changeset)
    end)
    |> Repo.transaction()
  end

  defp new_balance(prev, mins, :deduct), do: max(0, prev - mins)
  defp new_balance(prev, mins, :add), do: prev + mins
end
