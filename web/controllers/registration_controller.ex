defmodule IvanBloggo.RegistrationController do
  use IvanBloggo.Web, :controller

  alias IvanBloggo.User

  plug :scrub_params, "user" when action in [:create]
  plug :action

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)

    if changeset.valid? do
      Repo.insert(changeset)
      redirect conn, to: page_path(conn, :index)
    else
      render conn, "new.html", changeset: changeset
    end
  end

  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{}, :empty)
  end
end
