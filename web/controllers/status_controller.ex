defmodule IvanBloggo.StatusController do
  use IvanBloggo.Web, :controller

  plug :action

  def index(conn, _params) do
    text conn, "Ready"
  end
end
