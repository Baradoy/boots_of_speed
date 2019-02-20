defmodule BootsOfSpeedWeb.PageControllerTest do
  use BootsOfSpeedWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "BootsOfSpeed - A Gloomhaven Initiative Manager"
  end
end
