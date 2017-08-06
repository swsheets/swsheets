defmodule EdgeBuilder.Models.User do
  use EdgeBuilder.Web, :model

  @derive {Phoenix.Param, key: :username}
  schema "users" do
    field :username, :string
    field :email, :string
    field :password_reset_token, Ecto.UUID
    field :crypted_password, :binary
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :bug_reported_at, Ecto.DateTime
    field :pull_requested_at, Ecto.DateTime

    timestamps()
  end

  def changeset(user, context, params \\ %{})
  def changeset(user, :create, params) do
    user
    |> cast(params, ~w(username email password password_confirmation))
    |> shared_validations
    |> validate_required([:username, :email, :password])
    |> validate_format(:username, ~r/^[a-zA-Z0-9]*$/, message: "must contain only letters and numbers")
    |> validate_format(:username, ~r/^.{1,30}$/, message: "must contain no more than 30 characters")
  end

  def changeset(user, :update, params) do
    user
    |> cast(params, ~w(email password password_confirmation))
    |> shared_validations
  end

  def changeset(user, :password_reset, params) do
    user
    |> cast(params, ~w(password password_confirmation password_reset_token))
    |> shared_validations
  end

  def changeset(user, :contributions, params) do
    user
    |> cast(params, ~w(bug_reported_at pull_requested_at))
    |> shared_validations
  end

  defp shared_validations(changeset) do
    changeset
    |> unique_constraint(:username, name: :users_upper_username_index)
    |> unique_constraint(:email, name: :users_upper_email_index)
    |> validate_password_match
    |> validate_format(:password, ~r/^.{10,}$/, message: "must be at least 10 characters")
    |> validate_format(:email, ~r/@/, message: "must be a valid email address")
    |> crypt_password_if_present
  end

  def by_username(nil), do: nil
  def by_username(username) do
    Repo.one(
      from u in __MODULE__,
        where: fragment("upper(username)") == ^String.upcase(username)
    )
  end

  def contributors(limit \\ 1000) do
    Repo.all(
      from u in __MODULE__,
        where: fragment("bug_reported_at is not null or pull_requested_at is not null"),
        order_by: fragment("greatest(bug_reported_at, pull_requested_at) desc"),
        limit: ^limit
    )
  end

  def pull_requesters do
    Repo.all(
      from u in __MODULE__,
        where: fragment("pull_requested_at is not null"),
        order_by: [desc: :pull_requested_at]
    )
  end

  def bug_reporters do
    Repo.all(
      from u in __MODULE__,
        where: fragment("bug_reported_at is not null"),
        order_by: [desc: :bug_reported_at]
    )
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

  def crypt_password(pw) do
    Comeonin.Bcrypt.hashpwsalt(pw)
  end
end
