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

  describe "#create" do
    context "successful sign in" do
      it "adds the user's id to the session", %{conn: conn} do
        user = User.changeset(%User{}, @user_attrs) |> Repo.insert
        conn = post conn, session_path(conn, :create), @valid_params
        assert get_session(conn, :user_id) == user.id
      end

      it "redirects to the root path", %{conn: conn} do
        User.changeset(%User{}, @user_attrs) |> Repo.insert
        conn = post conn, session_path(conn, :create), @valid_params
        assert redirected_to(conn) == root_path(conn, :index)
      end

      it "sets the flash", %{conn: conn} do
        User.changeset(%User{}, @user_attrs) |> Repo.insert
        conn = post conn, session_path(conn, :create), @valid_params
        assert get_flash(conn, :info)
      end
    end

    context "incorrect password" do
      it "renders the new template with an error", %{conn: conn} do
        User.changeset(%User{}, @user_attrs) |> Repo.insert
        conn = post conn, session_path(conn, :create), @wrong_password_params
        html = html_response(conn, 200)
        assert text_for(html, "h2") == "Sign in"
        assert text_for(html, ".error") == "Incorrect email/password"
      end

      it "doesn't put the user id in the session", %{conn: conn} do
        User.changeset(%User{}, @user_attrs) |> Repo.insert
        conn = post conn, session_path(conn, :create), @wrong_password_params
        refute get_session(conn, :user_id)
      end
    end

    context "incorrect email" do
      it "renders the new template with an error", %{conn: conn} do
        conn = post conn, session_path(conn, :create), @wrong_password_params
        html = html_response(conn, 200)
        assert text_for(html, "h2") == "Sign in"
        assert text_for(html, ".error") == "Incorrect email/password"
      end

      it "doesn't put the user id in the session", %{conn: conn} do
        conn = post conn, session_path(conn, :create), @wrong_password_params
        refute get_session(conn, :user_id)
      end
    end
  end

  describe "#new" do
    it "renders the new template", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      html = html_response(conn, 200)

      assert text_for(html, "h2") == "Sign in"
      assert attribute_for(html, "form", "action") == [session_path(conn, :create)]
      assert text_for(html, "form label") =~ "Email"
      assert text_for(html, "form label") =~ "Password"
      assert attribute_for(html, "form label input", "name") == ["email", "password"]
      assert "Sign in" in attribute_for(html, "form input", "value")
    end
  end

  describe "#destroy" do
    it "clears the session", %{conn: conn} do
      User.changeset(%User{}, @user_attrs) |> Repo.insert
      conn = conn
        |> post(session_path(conn, :create), @valid_params)
        |> delete(session_path(conn, :delete))

      refute get_session(conn, :user_id)
    end

    it "redirects to the root", %{conn: conn} do
      conn = delete(conn, session_path(conn, :delete))
      assert redirected_to(conn) == root_path(conn, :index)
    end
  end
end
