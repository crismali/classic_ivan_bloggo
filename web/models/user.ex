defmodule IvanBloggo.User do
  use IvanBloggo.Web, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true

    timestamps
  end

  @required_fields ~w(email password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_unique(:email, on: Repo, downcase: true)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_confirmation(:password)
    |> set_encryped_password
    |> validate_length(:encrypted_password, is: 60)
  end

  defp set_encryped_password(changeset) do
    %{changes: changes} = changeset

    if changeset.valid? do
      encrypted_password = safe_hashpwsalt(changes[:password])
      changes_with_encrypted_password = Map.put(changes, :encrypted_password, encrypted_password)
      %{changeset | changes: changes_with_encrypted_password}
    else
      changeset
    end
  end

  defp safe_hashpwsalt(nil), do: nil
  defp safe_hashpwsalt(""), do: nil
  defp safe_hashpwsalt(password) when is_binary(password), do: hashpwsalt(password)
end
