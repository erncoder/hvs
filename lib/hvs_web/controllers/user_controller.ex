defmodule HVSWeb.UserController do
  @moduledoc """
  Controller for User-related routes.
  """

  use HVSWeb, :controller
  alias HVS.Users

  require Logger

  def create(conn, params) do
    case Users.create_user(params) do
      {:ok, %{id: id}} ->
        conn |> send_resp(201, "user created with id #{inspect(id)}\n")

      resp ->
        msg = "failed to create user with resp <<< #{inspect(resp)} >>>\n"
        Logger.error(msg)
        conn |> send_resp(500, msg)
    end
  end

  def index(conn, _params), do: conn |> send_resp(200, Users.list_users() |> Jason.encode!())

  def show(conn, %{"id" => user_id}),
    do: conn |> send_resp(200, Users.get_user(user_id) |> Jason.encode!())
end
