defmodule IvanBloggo.StatusControllerTest do
  use IvanBloggo.ConnCase

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  it "#index let's us know it's ready", %{conn: conn} do
    conn = get conn, status_path(conn, :index)
    assert conn.resp_body == "Ready"
  end
end
