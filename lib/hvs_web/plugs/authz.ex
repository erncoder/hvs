defmodule HVSWeb.Plugs.Authz do
  @moduledoc """
  Plug to enforce authorization.
  """

  import Plug.Conn

  def init(params), do: params

  def call(conn, :api), do: if(api_key_valid?(conn), do: conn, else: bad_resp(conn))

  defp api_key_valid?(conn) do
    valid_key = Application.fetch_env!(:hvs, :api_key)
    offered = conn |> Plug.Conn.get_req_header("x-api-key") |> List.first()
    offered === valid_key
  end

  defp bad_resp(conn), do: conn |> send_resp(401, "unauthorized\n") |> halt()
end
