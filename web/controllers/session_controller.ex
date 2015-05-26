defmodule IvanBloggo.SessionController do
  use IvanBloggo.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2]

  alias IvanBloggo.User

  plug :action

  def create(conn, %{"email" => email, "password" => password}) do
    user = Repo.get_by(User, email: email)

    if user do
      if checkpw(password, user.encrypted_password) do
        conn
          |> put_session(:user_id, user.id)
          |> put_flash(:info, "Successfully signed in!")
          |> redirect(to: root_path(conn, :index))
      else
        render conn, "new.html", error: true
      end
    else
      render conn, "new.html", error: true
    end
  end

  def new(conn, _params) do
    render conn, "new.html", error: false
  end

  def delete(conn, _params) do
    conn
      |> clear_session
      |> redirect(to: root_path(conn, :index))
  end
end
