defmodule EdgeBuilder.Models.User do
  use EdgeBuilder.Model

  schema "users" do
    field :username, :string
    field :email, :string
    field :crypted_password, :binary
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
  end

  def changeset(user, params) do
    user
      |> cast(params, ~w(username email password password_confirmation))
      |> crypt_password_if_present
  end

  def password_matches?(user, pw) do
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
