defmodule NoncegeekWeb.PageController do
  use NoncegeekWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

# File.write!("priv/static/images/1.jpg", body)
