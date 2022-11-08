defmodule NoncegeekWeb.PageController do
  @moduledoc false

  use NoncegeekWeb, :controller

  alias Noncegeek.Explorer

  def explorer(conn, _params) do
    {:ok, entries} = Explorer.paged_tokens()
    render(conn, :explorer, entries: entries)
  end
end
