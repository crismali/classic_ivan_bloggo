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

  describe "#changeset" do
    context "with valid attributes" do
      it "is valid" do
        changeset = User.changeset(%User{}, @valid_attrs)
        assert changeset.valid?
      end
    end

    context "with invalid attributes" do
      it "is invalid" do
        changeset = User.changeset(%User{}, @invalid_attrs)
        refute changeset.valid?
      end
    end
  end

  context "validations" do
    context "email" do
      it "must be present" do
        stripped_attrs = Dict.delete @valid_attrs, :email
        changeset = User.changeset(%User{}, stripped_attrs)
        refute changeset.valid?
        assert changeset.errors == [email: "can't be blank"]
      end

      context "must be unique" do
        it "is" do
          changeset = User.changeset(%User{}, @valid_attrs)
          Repo.insert(changeset)

          changeset = User.changeset(%User{}, @valid_attrs)

          refute changeset.valid?
          assert changeset.errors == [email: "has already been taken"]
        end

        it "is and case insensitive" do
          changeset = User.changeset(%User{}, @valid_attrs)
          Repo.insert(changeset)

          upcase_email = String.upcase(@valid_attrs.email)
          non_unique_attrs = Dict.put(@valid_attrs, :email, upcase_email)
          changeset = User.changeset(%User{}, non_unique_attrs)

          refute changeset.valid?
          assert changeset.errors == [email: "has already been taken"]
        end
      end

      it "validates its format" do
        poorly_formatted_attrs = Dict.put(@valid_attrs, :email, "not_an_email")
        changeset = User.changeset(%User{}, poorly_formatted_attrs)

        refute changeset.valid?
        assert changeset.errors == [email: "has invalid format"]
      end
    end

    context "encrypted_password" do
      context "must be present" do
        context "changes" do
          it "is invalid when nil" do
            invalid_attrs = Dict.merge(@valid_attrs, %{password: "nah", encrypted_password: nil})
            changeset = User.changeset(%User{}, invalid_attrs)

            refute changeset.valid?
            assert changeset.errors == [encrypted_password: "can't be blank", password_confirmation: "must match password"]
          end
        end

        context "model" do
          it "is invalid when set to nil" do
            changeset = User.changeset(%User{encrypted_password: nil}, %{email: "foo@example.com"})

            refute changeset.valid?
            assert changeset.errors == [encrypted_password: "can't be blank"]
          end

          it "is invalid when not present at all" do
            changeset = User.changeset(%User{}, %{email: "foo@example.com"})

            refute changeset.valid?
            assert changeset.errors == [encrypted_password: "can't be blank"]
          end
        end
      end

      context "must have a certain length" do
        it "is invalid when changed to an incorrect length" do
          incorrect_length_attrs = Dict.merge(@valid_attrs, %{password: "nah", encrypted_password: "incorrect length"})
          changeset = User.changeset(%User{}, incorrect_length_attrs)

          refute changeset.valid?
          assert changeset.errors == [
            encrypted_password: {"should be %{count} characters", 60},
            password_confirmation: "must match password"
          ]
        end

        it "is invalid when initialized to an incorrect length" do
          changeset = User.changeset(%User{encrypted_password: "wrong length"}, %{email: "dieh@rd.com"})

          refute changeset.valid?
          assert changeset.errors == [
            encrypted_password: {"should be %{count} characters", 60},
          ]
        end
      end
    end

    context "password and password_confirmation" do
      context "valid" do
        it "they match" do
          whitespaced_attrs = Dict.merge(@valid_attrs, %{password: " password", password_confirmation: "password "})
          changeset = User.changeset(%User{}, whitespaced_attrs)
          assert changeset.valid?
          assert changeset.errors == []
        end
      end

      context "invalid" do
        it "they are different" do
          non_matching_attrs = Dict.merge(@valid_attrs, %{password: "password", password_confirmation: "doesn't match"})
          changeset = User.changeset(%User{}, non_matching_attrs)
          refute changeset.valid?
          assert changeset.errors == [encrypted_password: "can't be blank", password_confirmation: "must match password"]
        end
      end
    end
  end

  context "setting encrypted_password based on password and password_confirmation" do
    context "password and password confirmation don't match" do
      it "does not set encrypted_password" do
        changeset = User.changeset(%User{}, %{password: "nope", password_confirmation: "nah"})
        refute changeset.changes[:encrypted_password]
      end
    end

    context "password and password confirmation match" do
      it "does not set it when they're nil" do
        changeset = User.changeset(%User{}, %{password: nil, password_confirmation: nil})
        refute changeset.changes[:encrypted_password]
      end

      it "does not set it when they're empty strings" do
        changeset = User.changeset(%User{}, %{password: "", password_confirmation: ""})
        refute changeset.changes[:encrypted_password]
      end

      it "sets encrypted_password when they're present" do
        changeset = User.changeset(%User{}, %{password: "password", password_confirmation: "password"})
        assert checkpw("password", changeset.changes.encrypted_password)
      end
    end
  end
end
