defmodule EdgeBuilder.Models.User do
  use EdgeBuilder.Model

  schema "users" do
    field :username, :string
    field :email, :string
    field :crypted_password, :binary
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  def changeset(user, context, params \\ %{})
  def changeset(user, :create, params) do
    user
      |> cast(params, ~w(username email password password_confirmation))
      |> validate_unique(:username, on: EdgeBuilder.Repo, downcase: true)
      |> crypt_password_if_present
  end

  def changeset(user, :update, params) do
    user
      |> cast(params, [], ~w(email password password_confirmation))
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
