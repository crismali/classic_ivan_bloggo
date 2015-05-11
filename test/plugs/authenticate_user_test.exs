defmodule IvanBloggo.AuthenticateUserTest do
  use IvanBloggo.ConnCase

  alias IvanBloggo.Plugs.AuthenticateUser
  alias IvanBloggo.Repo
  alias IvanBloggo.User

  setup do
    conn = conn()
    {:ok, conn: conn}
  end

  test "#init/1 returns its argument" do
    assert AuthenticateUser.init(5) == 5
    assert AuthenticateUser.init(3) == 3
  end

  @tag timeout: 9999999
  test "#call/2 when signed in", %{conn: conn} do
    email = "foo@example.com"
    password = "password"
    user_params = %{"email" => email, "password" => password, "password_confirmation" => password}
    user = User.changeset(%User{}, user_params) |> Repo.insert

    conn = conn
      |> post(session_path(conn, :create), %{email: email, password: password})
      |> AuthenticateUser.call("doesn't matter")

    %User{id: current_user_id, email: current_user_email} = conn.assigns.current_user
    assert current_user_id == user.id
    assert current_user_email == user.email
  end

  test "#call/2 when not signed in", %{conn: conn} do
    conn = conn
      |> sign_conn
      |> fetch_flash
      |> AuthenticateUser.call("doesn't matter")

    assert redirected_to(conn) == session_path(conn, :new)
    assert conn.halted
    assert get_flash(conn, :error)
  end

  @default_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt"
  ]

  @secret String.duplicate("abcdef0123456789", 8)
  @signing_opts Plug.Session.init(Keyword.put(@default_opts, :encrypt, false))

  defp sign_conn(conn) do
    put_in(conn.secret_key_base, @secret)
      |> Plug.Session.call(@signing_opts)
      |> fetch_session
  end
end
