defmodule EdgeBuilder.Controllers.PageControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.UserFactory
  alias Factories.CharacterFactory
  alias Factories.VehicleFactory

  describe "index" do
    it "shows a list of characters" do
      characters = [
        CharacterFactory.create_character(name: "Frank"),
        CharacterFactory.create_character(name: "Boba Fett")
      ]

      conn = build_conn() |> get("/")

      for character <- characters do
        assert String.contains?(conn.resp_body, character.name)
      end
    end

    it "shows a list of vehicles" do
      vehicles = [
        VehicleFactory.create_vehicle(name: "The Boss"),
        VehicleFactory.create_vehicle(name: "The Sauce")
      ]

      conn = build_conn() |> get("/")

      for vehicle <- vehicles do
        assert String.contains?(conn.resp_body, vehicle.name)
      end
    end

    it "shows a list of users who have contributed to the project in order of most recent contribution across types" do
      UserFactory.create_user!(username: "third") |> UserFactory.set_contributions(
        bug_reported_at:   %Ecto.DateTime{day: 5, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
        pull_requested_at: %Ecto.DateTime{day: 5, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user!(username: "second") |> UserFactory.set_contributions(
        bug_reported_at:   %Ecto.DateTime{day: 7, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
        pull_requested_at: %Ecto.DateTime{day: 2, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user!(username: "first") |> UserFactory.set_contributions(
        pull_requested_at: %Ecto.DateTime{day: 8, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user!(username: "nocontributions")

      conn = build_conn() |> get("/")

      assert String.match?(conn.resp_body, ~r/first.*second.*third/s)
      assert !String.contains?(conn.resp_body, "nocontributions")
    end

    it "shows a message if your password has just been reset" do
      user = UserFactory.create_user! |> UserFactory.add_password_reset_token

      conn = build_conn()
      |> post("/password-reset", %{"password_reset" => %{"password" => "asdasdasdasd", "password_confirmation" => "asdasdasdasd", "token" => user.password_reset_token}})
      |> get("/")

      assert String.contains?(conn.resp_body, "Your password has been reset and you are now logged in. Welcome back!")
    end

    it "shows no message if your password has not just been reset" do
      conn = build_conn() |> get("/")

      assert !String.contains?(conn.resp_body, "Your password has been reset and you are now logged in. Welcome back!")
    end
  end

  describe "thanks" do
    it "shows a full list of contributors" do
      UserFactory.create_user!(username: "mark") |> UserFactory.set_contributions(
        bug_reported_at:   %Ecto.DateTime{day: 5, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user!(username: "john") |> UserFactory.set_contributions(
        bug_reported_at:   %Ecto.DateTime{day: 7, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
        pull_requested_at: %Ecto.DateTime{day: 2, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      UserFactory.create_user!(username: "luke") |> UserFactory.set_contributions(
        pull_requested_at: %Ecto.DateTime{day: 8, month: 1, year: 2015, hour: 1, min: 1, sec: 1},
      )

      conn = build_conn() |> get("/thanks")

      assert String.contains?(conn.resp_body, "mark")
      assert String.contains?(conn.resp_body, "john")
      assert String.contains?(conn.resp_body, "luke")
    end
  end
end
