defmodule HVSWeb.APIController do
  @moduledoc """
  Controller for API routes.
  """

  use HVSWeb, :controller

  def check_access(conn, _params), do: conn |> send_resp(200, "API accessible\n")
end
