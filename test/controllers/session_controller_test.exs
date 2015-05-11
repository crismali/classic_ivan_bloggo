defmodule IvanBloggo.SessionControllerTest do
  use IvanBloggo.ConnCase

  import IvanBloggo.HtmlHelpers

  alias IvanBloggo.User

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  @password "password"
  @valid_params %{"email" => "foo@example.com", "password" => @password}
  @user_attrs Dict.merge(@valid_params, %{"password_confirmation" => @password})
  @wrong_password_params Dict.merge(@valid_params, %{"password" => ""})

  test "POST #create/2 when successful sign in", %{conn: conn} do
    user = create_user(@user_attrs)
    conn = post conn, session_path(conn, :create), @valid_params

    assert get_session(conn, :user_id) == user.id, "adds the user's id to the session"
    assert redirected_to(conn) == root_path(conn, :index), "redirects to the root path"
    assert get_flash(conn, :info), "sets the flash"
  end

  test "POST #create/2 with incorrect password", %{conn: conn} do
    create_user(@user_attrs)
    conn = post conn, session_path(conn, :create), @wrong_password_params
    html = html_response(conn, 200)

    assert text_for(html, "h2") == "Sign in", "it renders the sign in page"
    assert text_for(html, ".error") == "Incorrect email/password", "it renders an error"
    refute get_session(conn, :user_id), "it does not set the flash"
  end

  test "POST #create/2 with incorrect email", %{conn: conn} do
    conn = post conn, session_path(conn, :create), @wrong_password_params
    html = html_response(conn, 200)

    assert text_for(html, "h2") == "Sign in", "it renders the sign in page"
    assert text_for(html, ".error") == "Incorrect email/password", "it renders an error"
    refute get_session(conn, :user_id), "it does not set the flash"
  end

  test "GET #new/2", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    html = html_response(conn, 200)

    assert text_for(html, "h2") == "Sign in", "renders the header"
    assert attribute_for(html, "form", "action") == [session_path(conn, :create)], "has a form"
    assert text_for(html, "form label") =~ "Email", "it has an email field"
    assert text_for(html, "form label") =~ "Password", "it has a password field"
    assert attribute_for(html, "form label input", "name") == ["email", "password"], "it names the fields correctly"
    assert "Sign in" in attribute_for(html, "form input", "value"), "it can be submitted"
  end

  test "DELETE #delete/2" do
    create_user(@user_attrs)
    conn = conn
      |> post(session_path(conn, :create), @valid_params)
      |> delete(session_path(conn, :delete))

    refute get_session(conn, :user_id), "clears the session"
    assert redirected_to(conn) == root_path(conn, :index), "redirects to root"
  end

  defp create_user(params) do
    User.changeset(%User{}, params) |> Repo.insert
  end
end
