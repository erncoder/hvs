defmodule HVSWeb.UserController do
  @moduledoc """
  Controller for User-related routes.
  """

  use HVSWeb, :controller
  alias HVS.Users
  require Logger

  def index(conn, _params), do: conn |> send_resp(200, Users.list_users() |> Jason.encode!())

  def show(conn, %{"id" => user_id}),
    do: conn |> send_resp(200, Users.get_user!(user_id) |> Jason.encode!())

  def create(conn, params) do
    case Users.create_user(params) do
      {:ok, _user} ->
        conn |> put_status(201)

      resp ->
        Logger.error("failed to create user with resp <<< #{inspect(resp)} >>>")
        conn |> put_status(500)
    end
  end
end
