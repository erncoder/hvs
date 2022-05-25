defmodule HVS.VisitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HVS.Visits` context.
  """

  @doc """
  Generate a visit.
  """
  def visit_fixture(attrs \\ %{}) do
    {:ok, %HVS.Users.User{id: id}} = HVS.Users.create_user(%{
      first_name: "first",
      last_name: "last",
      email: "email",
      mins_balance: "30"
    })

    {:ok, visit} =
      attrs
      |> Enum.into(%{
        member: id,
        date: DateTime.utc_now(),
        minutes: 42,
        tasks: "some tasks"
      })
      |> HVS.Visits.create_visit()

    visit
  end
end
