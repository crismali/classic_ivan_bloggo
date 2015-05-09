defmodule IvanBloggo.User do
  use IvanBloggo.Web, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps
  end

  @required_fields ~w(email password password_confirmation encrypted_password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    processed_params = preprocess_params(params)
    model
    |> cast(processed_params, @required_fields, @optional_fields)
    |> validate_unique(:email, on: Repo, downcase: true)
    |> validate_format(:email, ~r/.+@.+\..+/)
    |> validate_length(:encrypted_password, is: 60)
    |> validate_password_matches_confirmation
  end

  defp preprocess_params(params) when is_map(params) do
    password = params["password"]
    password_confirmation = params["password_confirmation"]

    if password_and_confirmation_match?(password, password_confirmation) do
      Dict.put(params, "encrypted_password", safe_hashpwsalt(password))
    else
      params
    end
  end
  defp preprocess_params(arg), do: arg

  defp safe_hashpwsalt(nil), do: nil
  defp safe_hashpwsalt(""), do: nil
  defp safe_hashpwsalt(password) when is_binary(password), do: hashpwsalt(password)

  defp password_and_confirmation_match?(password, password_confirmation) do
    strip(password) == strip(password_confirmation)
  end

  defp validate_password_matches_confirmation(changeset) do
    %{changes: changes, errors: errors} = changeset
    password = changes[:password]
    password_confirmation = changes[:password_confirmation]

    new_error = password_error(password, password_confirmation)

    case new_error do
      []    -> changeset
      [_|_] -> %{changeset | errors: new_error ++ errors, valid?: false}
    end
  end

  defp password_error(password, password_confirmation) do
    if password_and_confirmation_match?(password, password_confirmation) do
      []
    else
      [password_confirmation: "must match password"]
    end
  end

  defp strip(nil), do: ""
  defp strip(suspect) when is_binary(suspect), do: String.strip(suspect)
end
