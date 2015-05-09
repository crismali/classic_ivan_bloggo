defmodule IvanBloggo.PostTest do
  use IvanBloggo.ModelCase

  alias IvanBloggo.Post

  @valid_attrs %{body: "some content", title: "some content"}
  @invalid_attrs %{}

  describe "#changeset" do
    it "with valid attributes is valid" do
      changeset = Post.changeset(%Post{}, @valid_attrs)
      assert changeset.valid?
    end

    it "with invalid attributes is invalid" do
      changeset = Post.changeset(%Post{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
