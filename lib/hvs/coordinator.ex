defmodule HVS.Coordinator do
  @moduledoc """
  Coordinates the creation and fulfillment of visits.
  """

  @compile if Mix.env() == :test, do: :export_all

  alias HVS.{
    Repo,
    Users,
    Users.User,
    Visits,
    Visits.Visit
  }

  require Logger

  @doc """
  Creates a visit if the requester has sufficient time balance.
  """
  def create_visit(
        %{
          "member" => member_id,
          "date" => date,
          "minutes" => minutes,
          "tasks" => tasks
        } = params
      )
      when "" not in [date, minutes, tasks] do
    with {:user, %User{mins_balance: balance}} <- {:user, Repo.get(User, member_id)},
         {:check, true} <- {:check, enough_mins?(minutes, balance)},
         {:created, {:ok, %Visit{id: id}}} <- {:created, Visits.create_visit(params)} do
      # param validators could be added here to filter out malformed data early
      {:ok, id}
    else
      {step, resp} ->
        msg = "failed to create visit on step #{inspect(step)} with response #{inspect(resp)}"
        Logger.error(msg)
        {:error, msg}
    end
  end

  def create_visit(_params), do: {:error, "missing one or more required fields"}

  @doc """
  Transfers minutes from a member to a pal and updates the appropriate visit
  with the pal's id.
  """
  def fulfill_visit(%{"pal_id" => pal_id, "visit_id" => visit_id})
      when "" not in [pal_id, visit_id] do
    with {:v, %Visit{member: m_id, minutes: mins, pal: nil} = visit} <-
           {:v, Visits.get_visit(visit_id)},
         {:m, %User{mins_balance: m_balance} = member} <- {:m, m_id |> Users.get_user()},
         {:p, %User{mins_balance: pal_balance} = pal} <- {:p, pal_id |> Users.get_user()},
         {:vcs, %{valid?: true} = visit_cs} <- {:vcs, Visits.change_visit(visit, %{pal: pal_id})},
         {:mcs, %{valid?: true} = member_cs} <-
           {:mcs,
            Users.change_user(member, %{mins_balance: new_balance(m_balance, mins, :deduct)})},
         {:pcs, %{valid?: true} = pal_cs} <-
           {:pcs, Users.change_user(pal, %{mins_balance: new_balance(pal_balance, mins, :add)})},
         {:insert, {:ok, _records}} <- {:insert, Repo.multi_upsert([member_cs, pal_cs, visit_cs])} do
      :ok
    else
      {step, resp} ->
        msg = "failed to create visit on step #{inspect(step)} with response #{inspect(resp)}"
        Logger.error(msg)
        {:error, msg}
    end
  end

  def fulfill_visit(_params), do: {:error, "missing one or more required fields"}

  defp enough_mins?(minutes, balance) when is_binary(minutes) do
    {mins, ""} = Integer.parse(minutes)
    enough_mins?(mins, balance)
  end

  defp enough_mins?(minutes, balance), do: balance > 0 and minutes <= balance
  defp new_balance(prev, mins, :deduct), do: floor(max(0, prev - mins))
  defp new_balance(prev, mins, :add), do: floor(0.85 * mins + prev)
end
