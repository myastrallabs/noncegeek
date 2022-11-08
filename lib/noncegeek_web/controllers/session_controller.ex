defmodule NoncegeekWeb.SessionController do
  @moduledoc false

  use NoncegeekWeb, :controller

  alias Noncegeek.Accounts
  alias NoncegeekWeb.UserAuth

  action_fallback NoncegeekWeb.FallbackController

  def create(conn, params) do
    with {:ok, user} <- Accounts.verify_wallet_address(params) do
      UserAuth.log_in_user(conn, user)
    end
  end

  def delete(conn, _params), do: UserAuth.log_out_user(conn)
end
