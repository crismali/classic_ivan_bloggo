defmodule IvanBloggo.RegistrationController do
  use IvanBloggo.Web, :controller

  alias IvanBloggo.User

  plug :scrub_params, "user" when action in [:create]
  plug :action

  def create(conn, %{"user" => user_params}) do
    user_params_with_defaults = merge_defaults(user_params)
    changeset = User.changeset(%User{}, user_params_with_defaults)

    if changeset.valid? do
      Repo.insert(changeset)
      redirect conn, to: root_path(conn, :index)
    else
      render conn, "new.html", changeset: changeset
    end
  end

  defp merge_defaults(%{"password_confirmation" => nil} = user_params) do
    %{user_params | "password_confirmation" => ""}
  end
  defp merge_defaults(user_params), do: user_params

  def new(conn, _params) do
    render conn, "new.html", changeset: User.changeset(%User{})
  end
end
