defmodule IvanBloggo.User do
  use IvanBloggo.Web, :model

  schema "users" do
    field :email, :string
    field :encrypted_password, :string

    timestamps
  end

  @required_fields ~w(email encrypted_password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_unique(:email, on: Repo, downcase: true)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_length(:encrypted_password, is: 60)
  end
end
