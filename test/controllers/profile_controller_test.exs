defmodule EdgeBuilder.Controllers.ProfileControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.UserFactory
  alias Factories.CharacterFactory
  alias Factories.VehicleFactory

  describe "show" do
    it "shows the username" do
      user = UserFactory.default_user

      conn = build_conn() |> get("/u/#{user.username}")

      assert String.contains?(conn.resp_body, user.username)
    end

    it "is case insensitive" do
      user = UserFactory.default_user

      conn = build_conn() |> get("/u/#{String.upcase(user.username)}")

      assert String.contains?(conn.resp_body, user.username)
    end

    test "shows a number of creations" do
      for {count, text} <- [{0, "0 Creations"}, {1, "1 Creation"}, {2, "2 Creations"}] do
        user = UserFactory.create_user!

        Stream.cycle([
          fn () -> CharacterFactory.create_character(user_id: user.id) end,
          fn () -> VehicleFactory.create_vehicle(user_id: user.id) end
        ]) |> Stream.take(count) |> Enum.map(&(&1.()))

        conn = build_conn() |> get("/u/#{user.username}")

        assert String.contains?(conn.resp_body, text), "Expected to find #{text}"
      end
    end

    it "shows a list of characters they have created" do
      user = UserFactory.default_user
      characters = [CharacterFactory.create_character(user_id: user.id), CharacterFactory.create_character(user_id: user.id)]

      conn = build_conn() |> get("/u/#{user.username}")

      for character <- characters do
        assert String.contains?(conn.resp_body, character.permalink)
      end
    end

    it "shows a list of vehicles they have created" do
      user = UserFactory.default_user
      vehicles = [VehicleFactory.create_vehicle(user_id: user.id), VehicleFactory.create_vehicle(user_id: user.id)]

      conn = build_conn() |> get("/u/#{user.username}")

      for vehicle <- vehicles do
        assert String.contains?(conn.resp_body, vehicle.permalink)
      end
    end
  end

  describe "my_creations" do
    it "displays a link to create a new character" do
      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/my-creations")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.character_path(conn, :new))
    end

    it "displays links for each character" do
      user = UserFactory.default_user

      characters = [
        CharacterFactory.create_character(name: "Frank", user_id: user.id),
        CharacterFactory.create_character(name: "Boba Fett", user_id: user.id)
      ]

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/my-creations")

      for character <- characters do
        assert String.contains?(conn.resp_body, character.name)
        assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.character_path(conn, :show, character))
      end
    end

    it "displays a link to create a new vehicle" do
      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/my-creations")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.vehicle_path(conn, :new))
    end

    it "displays links for each vehicle" do
      user = UserFactory.default_user

      vehicles = [
        VehicleFactory.create_vehicle(name: "Boo Bar", user_id: user.id),
        VehicleFactory.create_vehicle(name: "The Flier", user_id: user.id)
      ]

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/my-creations")

      for vehicle <- vehicles do
        assert String.contains?(conn.resp_body, vehicle.name)
        assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.vehicle_path(conn, :show, vehicle))
      end
    end

    it "requires authentication" do
      conn = build_conn() |> get("/my-creations")

      assert requires_authentication?(conn)
    end
  end
end
