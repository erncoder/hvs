defmodule HVSWeb.VisitController do
  @moduledoc """
  Controller for Visit-related routes.
  """
  use HVSWeb, :controller

  alias HVS.{
    Coordinator,
    Visits
  }

  def create(conn, params) do
    case Visits.create_visit(params) do
      {:ok, _visit} -> respond(conn, 201)
      resp -> respond(conn, 500, resp)
    end
  end

  def index(conn, _params), do: conn |> send_resp(200, Visits.list_visits() |> Jason.encode!())

  def show(conn, %{"id" => visit_id}),
    do: conn |> send_resp(200, Visits.get_visit(visit_id) |> Jason.encode!())

  def fulfill(conn, params) do
    case Coordinator.fulfill_visit(params) do
      :ok -> respond(conn, 201)
      resp -> respond(conn, 400, resp)
    end
  end

  def request(conn, params) do
    case Coordinator.create_visit(params) do
      {:ok, visit_id} -> respond(conn, 201, visit_id)
      {:error, error} -> respond(conn, 500, error)
    end
  end

  def respond(conn, code \\ 200, msg \\ "success") when is_integer(code),
    do: conn |> send_resp(code, inspect(msg) <> "\n")
end
