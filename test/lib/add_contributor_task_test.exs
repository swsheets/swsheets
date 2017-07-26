defmodule EdgeBuilder.Lib.AddContributorTaskTest do
  use EdgeBuilder.ModelCase

  alias Factories.UserFactory
  alias EdgeBuilder.Models.User

  describe "run" do
    it "marks a bug reporter" do
      user = UserFactory.default_user

      Mix.Tasks.AddContributor.run([user.username, "bug"])

      user = EdgeBuilder.Repo.get(User, user.id)
      assert !is_nil(user.bug_reported_at)
    end

    it "marks a pull requester" do
      user = UserFactory.default_user

      Mix.Tasks.AddContributor.run([user.username, "pull_request"])

      user = EdgeBuilder.Repo.get(User, user.id)
      assert !is_nil(user.pull_requested_at)
    end
  end
end
