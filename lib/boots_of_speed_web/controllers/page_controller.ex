defmodule BootsOfSpeedWeb.PageController do
  use BootsOfSpeedWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
