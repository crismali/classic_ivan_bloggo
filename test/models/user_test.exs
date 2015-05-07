defmodule IvanBloggo.UserTest do
  use IvanBloggo.ModelCase

  alias IvanBloggo.User

  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]

  @valid_attrs %{
    email: "foo@example.com",
    password: "password",
    password_confirmation: "password",
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "validates presence of email" do
    stripped_attrs = Dict.delete @valid_attrs, :email
    changeset = User.changeset(%User{}, stripped_attrs)
    refute changeset.valid?
    assert changeset.errors == [email: "can't be blank"]
  end

  test "validates uniqueness of email" do
    changeset = User.changeset(%User{}, @valid_attrs)
    Repo.insert(changeset)

    upcase_email = String.upcase(@valid_attrs.email)
    non_unique_attrs = Dict.put(@valid_attrs, :email, upcase_email)
    changeset = User.changeset(%User{}, non_unique_attrs)

    refute changeset.valid?
    assert changeset.errors == [email: "has already been taken"]
  end

  test "validates format of email" do
    poorly_formatted_attrs = Dict.put(@valid_attrs, :email, "not_an_email")
    changeset = User.changeset(%User{}, poorly_formatted_attrs)

    refute changeset.valid?
    assert changeset.errors == [email: "has invalid format"]
  end

  test "validates presence of encrypted_password" do
    # changes
    invalid_attrs = Dict.merge(@valid_attrs, %{password: "nah", encrypted_password: nil})
    changeset = User.changeset(%User{}, invalid_attrs)

    refute changeset.valid?
    assert changeset.errors == [encrypted_password: "can't be blank", password_confirmation: "must match password"]

    stripped_attrs = Dict.delete @valid_attrs, :password
    changeset = User.changeset(%User{}, stripped_attrs)

    refute changeset.valid?
    assert changeset.errors == [encrypted_password: "can't be blank", password_confirmation: "must match password"]

    # model
    changeset = User.changeset(%User{encrypted_password: nil}, %{email: "foo@example.com"})

    refute changeset.valid?
    assert changeset.errors == [encrypted_password: "can't be blank"]

    changeset = User.changeset(%User{}, %{email: "foo@example.com"})

    refute changeset.valid?
    assert changeset.errors == [encrypted_password: "can't be blank"]
  end

  test "validates length of encrypted_password" do
    # changes
    incorrect_length_attrs = Dict.merge(@valid_attrs, %{password: "nah", encrypted_password: "incorrect length"})
    changeset = User.changeset(%User{}, incorrect_length_attrs)

    refute changeset.valid?
    assert changeset.errors == [
      encrypted_password: {"should be %{count} characters", 60},
      password_confirmation: "must match password"
    ]

    # model
    changeset = User.changeset(%User{encrypted_password: "wrong length"}, %{email: "dieh@rd.com"})

    refute changeset.valid?
    assert changeset.errors == [
      encrypted_password: {"should be %{count} characters", 60},
    ]
  end

  test "validates password and password confirmation are the same" do
    non_matching_attrs = Dict.merge(@valid_attrs, %{password: "password", password_confirmation: "doesn't match"})
    changeset = User.changeset(%User{}, non_matching_attrs)
    refute changeset.valid?
    assert changeset.errors == [encrypted_password: "can't be blank", password_confirmation: "must match password"]

    non_matching_attrs = Dict.merge(@valid_attrs, %{password: " password", password_confirmation: "password "})
    changeset = User.changeset(%User{}, non_matching_attrs)
    assert changeset.valid?
    assert changeset.errors == []
  end

  test "it sets encrypted_password when password and password confirmation are present and match" do
    changeset = User.changeset(%User{}, %{password: nil, password_confirmation: nil})
    refute changeset.changes[:encrypted_password]

    changeset = User.changeset(%User{}, %{password: "nope", password_confirmation: "nah"})
    refute changeset.changes[:encrypted_password]

    changeset = User.changeset(%User{}, %{password: "", password_confirmation: ""})
    refute changeset.changes[:encrypted_password]

    changeset = User.changeset(%User{}, %{password: "password", password_confirmation: "password"})
    assert checkpw("password", changeset.changes.encrypted_password)
  end

  test "#count is the number of users" do
    assert User.count == 0
    changeset = User.changeset(%User{}, @valid_attrs)
    Repo.insert(changeset)
    assert User.count == 1
  end
end
