defmodule EdgeBuilder.Models.Announcement do
  use EdgeBuilder.Web, :model

  schema "announcements" do
    field :active, :boolean, default: false
    field :body, :string
    field :level, :string

    timestamps()
  end

  def changeset(announcements, attrs) do
    announcements
    |> cast(attrs, [:body, :level, :active])
    |> validate_required([:body, :level, :active])
    |> validate_inclusion(:level, ["danger", "warning", "info", "success"])
  end

  def active() do
    Repo.all(
      from a in __MODULE__,
        where: a.active,
        order_by: [desc: a.inserted_at]
    )
  end
end
