defmodule EdgeBuilder.Models.User do
  use EdgeBuilder.Web, :model

  schema "users" do
    field :username, :string
    field :email, :string
    field :password_reset_token, Ecto.UUID
    field :crypted_password, :binary
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  def changeset(user, context, params \\ %{})
  def changeset(user, :create, params) do
    user
    |> cast(params, ~w(username email password), ~w(password_confirmation))
    |> shared_validations
    |> validate_unique(:username, on: EdgeBuilder.Repo, downcase: true)
    |> validate_format(:username, ~r/^[a-zA-Z0-9]*$/, message: "must contain only letters and numbers")
    |> validate_format(:username, ~r/^.{1,30}$/, message: "must contain no more than 30 characters")
  end

  def changeset(user, :update, params) do
    user
    |> cast(params, [], ~w(email password password_confirmation))
    |> shared_validations
  end

  def changeset(user, :password_reset, params) do
    user
    |> cast(params, [], ~w(password password_confirmation password_reset_token))
    |> shared_validations
  end

  defp shared_validations(changeset) do
    changeset
    |> validate_password_match
    |> validate_format(:password, ~r/^.{10,}$/, message: "must be at least 10 characters")
    |> validate_format(:email, ~r/@/, message: "must be a valid email address")
    |> crypt_password_if_present
  end

  def authenticate(username, pw) do
    user = EdgeBuilder.Repo.one(from u in __MODULE__, where: u.username == ^username)

    if password_matches?(user, pw) do
      {:ok, user}
    else
      {:error, ["No user with that password could be found"]}
    end
  end

  defp validate_password_match(changeset) do
    password = get_change(changeset, :password)
    confirmation = get_change(changeset, :password_confirmation)

    if !is_nil(password) && password != confirmation do
      add_error(changeset, :password, "does not match the confirmation")
    else
      changeset
    end
  end

  defp password_matches?(nil, _), do: Comeonin.Bcrypt.dummy_checkpw
  defp password_matches?(user, pw) do
    Comeonin.Bcrypt.checkpw(pw, user.crypted_password)
  end

  defp crypt_password_if_present(changeset) do
    case Ecto.Changeset.get_change(changeset, :password) do
      nil -> changeset
      pw -> Ecto.Changeset.put_change(changeset, :crypted_password, crypt_password(pw))
    end
  end

  defp crypt_password(pw) do
    Comeonin.Bcrypt.hashpwsalt(pw)
  end
end
