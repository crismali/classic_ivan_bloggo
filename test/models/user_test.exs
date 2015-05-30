defmodule IvanBloggo.UserTest do
  use IvanBloggo.ModelCase
  alias IvanBloggo.User

  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]

  @valid_attrs %{
    "email" => "foo@example.com",
    "password" => "password",
    "password_confirmation" => "password",
  }
  @attrs_without_password %{
    "email" => "foo@example.com",
    "password_confirmation" => "something",
    "encrypted_password" => hashpwsalt("password")
  }
  @attrs_without_password_confirmation %{
    "email" => "foo@example.com",
    "password" => "something",
    "encrypted_password" => hashpwsalt("password")
  }
  @attrs_non_matching_password %{
    "email" => "foo@example.com",
    "password" => "password",
    "password_confirmation" => "passwerd",
  }

  @blank_error_message "can't be blank"
  @must_match_message "must match password"

  @invalid_attrs %{}

  describe "#changeset" do
    context "with valid attributes" do
      # it "is valid" do
      #   changeset = User.changeset(%User{}, @valid_attrs)
      #   assert changeset.valid?
      # end
    end

    context "with invalid attributes" do
      # it "is invalid" do
      #   changeset = User.changeset(%User{}, @invalid_attrs)
      #   refute changeset.valid?
      # end
    end
  end

  context "validations" do
    test "required fields" do
      changeset = User.changeset(%User{})

      assert :email in changeset.required
      assert :password in changeset.required
    end

    test "email is unique" do
      changeset = User.changeset(%User{})

      assert {:email, {:unique, [on: Repo, downcase: true]}} in changeset.validations
    end

    test "email is formatted" do
      changeset = User.changeset(%User{})

      assert {:email, {:format, ~r/.+@.+\..+/}} in changeset.validations
    end

    test "encrypted_password must be 60 characters" do
      changeset = User.changeset(%User{})

      assert {:encrypted_password, {:length, [is: 60]}} in changeset.validations
    end

    test "password matches password_confirmation" do
      changeset = User.changeset(%User{})

      assert {:password, {:confirmation, []}} in changeset.validations
    end
  end

  context "setting encrypted_password based on password and password_confirmation" do
    context "password and password confirmation don't match" do
      it "does not set encrypted_password" do
        changeset = User.changeset(%User{}, %{"password" => "nope", "password_confirmation" => "nah"})
        refute changeset.changes[:encrypted_password]
      end
    end

    context "password and password confirmation match" do
      it "does not set it when they're nil" do
        changeset = User.changeset(%User{}, %{"password" => nil, "password_confirmation" => nil})
        refute changeset.changes[:encrypted_password]
      end

      it "does not set it when they're empty strings" do
        changeset = User.changeset(%User{}, %{"password" => "", "password_confirmation" => ""})
        refute changeset.changes[:encrypted_password]
      end

      it "sets encrypted_password when they're present" do
        changeset = User.changeset(%User{email: "foo@bar.com"}, %{"password" => "password", "password_confirmation" => "password"})

        assert checkpw("password", changeset.changes.encrypted_password)
      end
    end
  end
end
