defmodule IvanBloggo.User do
  use IvanBloggo.Web, :model

  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2]

  schema "users" do
    field :email, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps
  end

  @required_fields ~w(email password password_confirmation)
  @optional_fields ~w(encrypted_password)

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
    |> validate_password_matches_confirmation
    |> validate_encrypted_password_present_and_correct_length
  end

  defp validate_encrypted_password_present_and_correct_length(changeset) do
    %{changes: changes, errors: errors, model: model} = changeset

    new_error = encrypted_password_error(changes, model)

    case new_error do
      []    -> changeset
      [_|_] ->
        %{changeset | errors: new_error ++ errors, valid?: false}
    end
  end

  defp encrypted_password_error(changes, model) do
    encrypted_password = changes[:encrypted_password] || model.encrypted_password

    if encrypted_password |> strip |> string_present? do
      if String.length(encrypted_password) == 60 do
        []
      else
        [encrypted_password: {"should be %{count} characters", 60}]
      end
    else
      [encrypted_password: "can't be blank"]
    end
  end

  defp validate_password_matches_confirmation(changeset) do
    %{changes: changes, errors: errors} = changeset
    password = changes[:password] |> strip
    password_confirmation = changes[:password_confirmation] |> strip

    new_error = password_error(password, password_confirmation)

    case new_error do
      []    ->
        %{changeset | changes: set_encrypted_password(changes, password)}
      [_|_] ->
        %{changeset | errors: new_error ++ errors, valid?: false}
    end
  end

  defp set_encrypted_password(changes, password) do
    if string_present?(password) do
      Dict.put(changes, :encrypted_password, hashpwsalt(password))
    else
      changes
    end
  end

  defp password_error(password, password_confirmation) do
    if password == password_confirmation do
      []
    else
      [password_confirmation: "must match password"]
    end
  end

  defp string_present?(suspect), do: String.length(suspect) != 0

  defp strip(nil), do: ""
  defp strip(suspect) when is_binary(suspect), do: String.strip(suspect)
end
