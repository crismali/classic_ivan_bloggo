defmodule IvanBloggo.UserTest do
  use IvanBloggo.ModelCase

  alias IvanBloggo.User

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  @valid_attrs %{
    email: "foo@example.com",
    encrypted_password: hashpwsalt("foo")
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
    stripped_attrs = Dict.delete @valid_attrs, :encrypted_password
    changeset = User.changeset(%User{}, stripped_attrs)

    refute changeset.valid?
    assert changeset.errors == [encrypted_password: "can't be blank"]
  end

  test "validates length of encrypted_password" do
    incorrect_length_attrs = Dict.put(@valid_attrs, :encrypted_password, "wrong encrypted password length")
    changeset = User.changeset(%User{}, incorrect_length_attrs)

    refute changeset.valid?
    assert changeset.errors == [encrypted_password: {"should be %{count} characters", 60}]
  end

  test "#count is the number of users" do
    assert User.count == 0
    changeset = User.changeset(%User{}, @valid_attrs)
    Repo.insert(changeset)
    assert User.count == 1
  end
end
