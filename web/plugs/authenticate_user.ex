defmodule IvanBloggo.Plugs.AuthenticateUser do
  use IvanBloggo.Web, :controller

  plug :action

  alias IvanBloggo.User

  def init(default), do: default

  def call(conn, _default) do
    user_id = get_session(conn, :user_id)

    if user_id do
      user = Repo.get(User, user_id)
      assign(conn, :current_user, user)
    else
      conn
        |> put_flash(:error, "You must be signed in to do that")
        |> redirect(to: session_path(conn, :new))
        |> halt
    end
  end
end
