defmodule EdgeBuilder.Models.AnnouncementTest do
  use EdgeBuilder.ModelCase

  alias Factories.AnnouncementFactory
  alias EdgeBuilder.Models.Announcement
  # alias EdgeBuilder.Repo

  describe "announcement" do
    @valid_attrs %{
      "body" => "This is the body of an announcement"
    }

    it "defaults to inactive" do
      announcement = AnnouncementFactory.create_announcement()

      assert announcement.active == false
    end

    it "only allows valid levels" do
      attrs = Map.put(@valid_attrs, "level", "not_valid")
      changeset = Announcement.changeset(%Announcement{}, attrs)

      assert [
               level:
                 {"is invalid",
                  [validation: :inclusion, enum: ["danger", "warning", "info", "success"]]}
             ] == changeset.errors()
    end
  end
end
