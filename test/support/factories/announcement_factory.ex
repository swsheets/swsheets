defmodule Factories.AnnouncementFactory do
  use Factories.BaseFactory

  alias EdgeBuilder.Models.Announcement
  alias EdgeBuilder.Repo

  @defaults %{
    body: "This is the body not shown",
    level: "warning"
  }

  def create_announcement(overrides \\ []) do
    params = Enum.into(overrides, @defaults)

    Announcement.changeset(%Announcement{}, parameterize(params))
    |> Repo.insert!()
  end

  def default_parameters do
    @defaults |> parameterize
  end
end
