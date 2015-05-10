defmodule IvanBloggo.RegistrationControllerTest do
  use IvanBloggo.ConnCase

  import IvanBloggo.HtmlHelpers

  alias IvanBloggo.User

  @valid_params user: %{
    email: "foo@example.com",
    password: "password",
    password_confirmation: "password"
  }
  @invalid_params user: %{email: "", password: ""}

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  describe "#new/2" do
    it "renders the new template", %{conn: conn} do
      response_text = conn
        |> get(registration_path(conn, :new))
        |> html_response(200)
        |> text_for("body")

      assert response_text =~ "Sign up today!"
      refute response_text =~ "can't be blank"
    end
  end

  describe "#create/2" do
    context "with valid data" do
      it "redirects to the root", %{conn: conn} do
        conn = post conn, registration_path(conn, :create), @valid_params
        assert redirected_to(conn) == root_path(conn, :index)
      end

      it "creates a user with the given params", %{conn: conn} do
        assert count(User) == 0
        post conn, registration_path(conn, :create), @valid_params
        assert count(User) == 1
      end
    end

    context "with invalid data" do
      it "with invalid data renders the new template with errors", %{conn: conn} do
        conn = post conn, registration_path(conn, :create), @invalid_params
        response = html_response(conn, 200)

        assert response =~ "Sign up today!"
        assert text_for(response, "label") =~ "can't be blank"
      end

      it "does not create a new user" do
        assert count(User) == 0
        post conn, registration_path(conn, :create), @invalid_params
        assert count(User) == 0
      end
    end
  end
end
