defmodule HVS.VisitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `HVS.Visits` context.
  """

  @doc """
  Generate a visit.
  """
  def visit_fixture(attrs \\ %{}) do
    {:ok, visit} =
      attrs
      |> Enum.into(%{
        date: ~U[2022-05-24 03:39:00Z],
        minutes: 42,
        tasks: "some tasks"
      })
      |> HVS.Visits.create_visit()

    visit
  end
end
