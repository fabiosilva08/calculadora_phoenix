defmodule MeuAppWeb.PageController do
  use MeuAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
