defmodule EdgeBuilder.Controllers.CharacterControllerTest do
  use EdgeBuilder.ConnCase

  alias Factories.CharacterFactory
  alias Factories.UserFactory
  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Models.Talent
  alias EdgeBuilder.Models.Attack
  alias EdgeBuilder.Models.BaseSkill
  alias EdgeBuilder.Models.CharacterSkill
  alias EdgeBuilder.Models.ForcePower
  alias EdgeBuilder.Models.ForcePowerUpgrade
  alias EdgeBuilder.Repo
  alias Helpers.FlokiExt
  import Ecto.Query, only: [from: 2]

  describe "new" do
    it "renders the character edit form for a new character" do
      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/c/new")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, "New Character")
    end

    it "requires authentication" do
      conn = build_conn() |> get("/c/new")

      assert requires_authentication?(conn)
    end

    it "renders characteristics next to skills" do
      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/c/new")

      assert String.contains?(conn.resp_body, "Astrogation (Int)")
      assert String.contains?(conn.resp_body, "Athletics (Br)")
      assert String.contains?(conn.resp_body, "Charm (Pr)")
      assert String.contains?(conn.resp_body, "Coercion (Will)")
      assert String.contains?(conn.resp_body, "Coordination (Ag)")
      assert String.contains?(conn.resp_body, "Deception (Cun)")
    end
  end

  describe "create" do
    it "creates a character" do
      base_skills = BaseSkill.all
      |> Enum.reject(&(&1.name == "Athletics"))
      |> Enum.with_index
      |> Enum.map(fn {skill, index} ->
          {index, %{"base_skill_id" => skill.id, "rank" => "0"}}
        end)
      |> Enum.into(%{})

      skills_with_user_edit = base_skills
      |> Map.put("Athletics", %{"base_skill_id" => BaseSkill.by_name("Athletics").id, "rank" => "3", "is_career" => "on", "characteristic" => "Brawn"})

      build_conn() |> authenticate_as(UserFactory.default_user) |> post("/c", %{
        "character" => %{
          "name" => "Greedo",
          "species" => "Rodian",
          "career" => "Bounty Hunter",
          "system" => "eote",
          "credits" => "3000",
          "defense_melee" => "1",
          "defense_ranged" => "2",
          "encumbrance" => "5 / 8",
          "motivation" => "Kill some dudes",
          "obligation" => "(10 pts) Has to kill some dudes",
          "soak" => "3",
          "specializations" => "Hired Gun",
          "strain_current" => "4",
          "strain_threshold" => "5",
          "wounds_current" => "",
          "wounds_threshold" => "7",
          "xp_available" => "100",
          "xp_total" => "200",
          "background" => "A regular Rodian, you know",
          "description" => "Green",
          "other_notes" => "Not the best",
        },
        "attacks" => %{
          "0" => %{"critical" => "3", "damage" => "4", "range" => "Short", "base_skill_id" => BaseSkill.by_name("Ranged: Light").id, "specials" => "Stun Setting", "weapon_name" => "Holdout Blaster"},
          "1" => %{"id" => "", "critical" => "5", "damage" => "+1", "range" => "Engaged", "base_skill_id" => BaseSkill.by_name("Brawl").id, "specials" => "", "weapon_name" => "Claws"}
        },
        "skills" => skills_with_user_edit,
        "talents" => %{
          "0" => %{"book_and_page" => "EotE p25", "description" => "Draw as incidental", "name" => "Quick Draw"},
          "1" => %{"book_and_page" => "DC p200", "description" => "Upgrade all checks by one", "name" => "Adversary 1"}
        },
      })

      character = Repo.all(Character) |> Enum.at(0)

      assert character.user_id == UserFactory.default_user.id
      assert character.name == "Greedo"
      assert character.species == "Rodian"
      assert character.career == "Bounty Hunter"
      assert character.credits == 3000
      assert character.defense_melee == 1
      assert character.defense_ranged == 2
      assert character.encumbrance == "5 / 8"
      assert character.motivation == "Kill some dudes"
      assert character.obligation == "(10 pts) Has to kill some dudes"
      assert character.soak == 3
      assert character.specializations == "Hired Gun"
      assert character.strain_current == 4
      assert character.strain_threshold == 5
      assert is_nil(character.wounds_current)
      assert character.wounds_threshold == 7
      assert character.xp_available == 100
      assert character.xp_total == 200
      assert character.background == "A regular Rodian, you know"
      assert character.description == "Green"
      assert character.other_notes == "Not the best"

      [first_attack, second_attack] = Attack.for_character(character.id)

      assert first_attack.critical == "3"
      assert first_attack.damage == "4"
      assert first_attack.range == "Short"
      assert first_attack.base_skill_id == BaseSkill.by_name("Ranged: Light").id
      assert first_attack.specials == "Stun Setting"
      assert first_attack.weapon_name == "Holdout Blaster"

      assert second_attack.critical == "5"
      assert second_attack.damage == "+1"
      assert second_attack.range == "Engaged"
      assert second_attack.base_skill_id == BaseSkill.by_name("Brawl").id
      assert second_attack.specials == nil
      assert second_attack.weapon_name == "Claws"

      [first_talent, second_talent] = Talent.for_character(character.id)

      assert first_talent.book_and_page == "EotE p25"
      assert first_talent.description == "Draw as incidental"
      assert first_talent.name == "Quick Draw"

      assert second_talent.book_and_page == "DC p200"
      assert second_talent.description == "Upgrade all checks by one"
      assert second_talent.name == "Adversary 1"

      [character_skill] = CharacterSkill.for_character(character.id)

      assert character_skill.base_skill_id == BaseSkill.by_name("Athletics").id
      assert character_skill.is_career
      assert character_skill.rank == 3
      assert character_skill.characteristic == "Brawn"
    end

    it "creates a Force & Destiny character" do
      build_conn() |> authenticate_as(UserFactory.default_user) |> post("/c", %{
        "character" => %{
          "name" => "Ki Ar Mundi",
          "species" => "Big headed folks",
          "career" => "Jedi Manager",
          "system" => "fad",
          "morality" => "not so hot!",
          "force_rating" => "5"
        },
        "force_powers" => %{
          "0" => %{"name" => "Motivate", "description" => "Gets people up and at em!", "display_order" => "1", "force_power_upgrades" => %{
              "0" => %{"name" => "Improved Productivity", "description" => "People work ten percent harder", "display_order" => "0"},
              "1" => %{"name" => "Greater Productivity", "description" => "People work fifteen percent harder", "display_order" => "1"}
              }
          },
          "1" => %{"name" => "Force Feedback", "description" => "Give effective individual feedback", "display_order" => "0"}
        }
      })

      character = Repo.all(Character) |> Enum.at(0)

      assert character.user_id == UserFactory.default_user.id
      assert character.name == "Ki Ar Mundi"
      assert character.force_rating == 5
      assert character.morality == "not so hot!"

      [first_power, second_power] = ForcePower.for_character(character.id) |> Enum.sort_by(&(&1.display_order))

      assert first_power.name == "Force Feedback"
      assert first_power.description == "Give effective individual feedback"
      assert first_power.display_order == 0

      assert second_power.name == "Motivate"
      assert second_power.description == "Gets people up and at em!"
      assert second_power.display_order == 1

      [first_upgrade, second_upgrade] = second_power.force_power_upgrades
      assert first_upgrade.name == "Improved Productivity"
      assert first_upgrade.description == "People work ten percent harder"
      assert first_upgrade.display_order == 0

      assert second_upgrade.name == "Greater Productivity"
      assert second_upgrade.description == "People work fifteen percent harder"
      assert second_upgrade.display_order == 1
    end

    it "redirects to the character show page" do
      params = CharacterFactory.default_parameters
      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> post("/c", %{"character" => params})

      character = Repo.one!(from c in Character, where: c.name == ^params["name"]) |> Character.set_permalink

      assert is_redirect_to?(conn, EdgeBuilder.Router.Helpers.character_path(conn, :show, character))
    end

    it "re-renders the new character page when there are errors" do
      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> post("/c", %{
        "character" => %{
          "species" => "Rodian",
          "career" => "Bounty Hunter",
          "system" => "eote"
        },
        "skills" => %{"0" => %{"base_skill_id" => BaseSkill.by_name("Athletics").id, "rank" => "3", "is_career" => "on"}},
        "force_powers" => %{
          "0" => %{"name" => "Motivate", "description" => "Gets people up and at em!", "display_order" => "1", "force_power_upgrades" => %{
              "0" => %{"name" => "Improved Productivity", "description" => "People work ten percent harder", "display_order" => "0"}
              }
          }
        }
      })

      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text == "Name can't be blank"
      assert FlokiExt.element(conn, "[data-skill=Athletics]") |> FlokiExt.find("input[type=text]") |> FlokiExt.attribute("value") == "3"
      assert !is_nil(FlokiExt.element(conn, ".attack-first-row"))
      assert !is_nil(FlokiExt.element(conn, ".talent-row"))

      assert String.contains?(conn.resp_body, "Gets people up and at em!")
      assert String.contains?(conn.resp_body, "People work ten percent harder")
    end

    it "requires authentication" do
      conn = build_conn() |> post("/c")

      assert requires_authentication?(conn)
    end

    it "respects the original ordering of the talents and attacks from the page" do
      build_conn() |> authenticate_as(UserFactory.default_user) |> post("/c", %{
        "character" => %{
          "name" => "Greedo",
          "species" => "Rodian",
          "career" => "Bounty Hunter",
          "system" => "eote"
        },
        "attacks" => %{
          "1" => %{"critical" => "3", "damage" => "4", "range" => "Short", "base_skill_id" => BaseSkill.by_name("Ranged: Light").id, "specials" => "Stun Setting", "weapon_name" => "Holdout Blaster", "display_order" => "1"},
          "10" => %{"id" => "", "critical" => "5", "damage" => "+1", "range" => "Engaged", "base_skill_id" => BaseSkill.by_name("Brawl").id, "specials" => "", "weapon_name" => "Fists", "display_order" => "10"},
          "2" => %{"id" => "", "critical" => "5", "damage" => "+1", "range" => "Engaged", "base_skill_id" => BaseSkill.by_name("Brawl").id, "specials" => "", "weapon_name" => "Claws", "display_order" => "2"}
        },
        "talents" => %{
          "1" => %{"book_and_page" => "EotE p25", "description" => "Draw as incidental", "name" => "Quick Draw", "display_order" => "1"},
          "10" => %{"book_and_page" => "DC p200", "description" => "Upgrade all checks by one", "name" => "Adversary 1", "display_order" => "10"},
          "2" => %{"book_and_page" => "NR 100", "description" => "Launch a fire bomb attack", "name" => "Fire Bomb", "display_order" => "2"}
        },
      })

      character = Repo.all(Character) |> Enum.at(0) |> Character.set_permalink

      conn = get(build_conn(), "/c/#{character.permalink}")

      assert String.match?(conn.resp_body, ~r/Quick Draw.*Fire Bomb.*Adversary 1/s)
      assert String.match?(conn.resp_body, ~r/Holdout Blaster.*Claws.*Fists/s)
    end
  end

  describe "show" do
    it "displays the character information" do
      character = CharacterFactory.create_character

      conn = build_conn() |> get("/c/#{character.permalink}")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, character.name)
    end

    it "displays edit and delete buttons when viewed by the owner" do
      character = CharacterFactory.create_character(user_id: UserFactory.default_user.id)

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/c/#{character.permalink}")

      assert String.contains?(conn.resp_body, "Edit")
      assert String.contains?(conn.resp_body, "Delete")
    end

    it "inserts appropriate line breaks for long text fields" do
      character = CharacterFactory.create_character(personal_gear: "Belt\nWatch")

      conn = build_conn() |> get("/c/#{character.permalink}")

      assert String.contains?(conn.resp_body, "Belt<br>Watch")
    end

    it "escapes HTML input in text fields" do
      character = CharacterFactory.create_character(personal_gear: "Belt<script></script>Watch")

      conn = build_conn() |> get("/c/#{character.permalink}")

      assert !String.contains?(conn.resp_body, "Belt<script></script>Watch")
    end

    it "renders characteristics next to skills" do
      character = CharacterFactory.create_character

      conn = build_conn() |> get("/c/#{character.permalink}")

      assert String.contains?(conn.resp_body, "Astrogation (Int)")
      assert String.contains?(conn.resp_body, "Athletics (Br)")
      assert String.contains?(conn.resp_body, "Charm (Pr)")
      assert String.contains?(conn.resp_body, "Coercion (Will)")
      assert String.contains?(conn.resp_body, "Coordination (Ag)")
      assert String.contains?(conn.resp_body, "Deception (Cun)")
    end

    it "displays partial attacks" do
      character = CharacterFactory.create_character
      Repo.insert!(%Attack{character_id: character.id, weapon_name: "Claws"})

      conn = build_conn() |> get("/c/#{character.permalink}")

      assert String.contains?(conn.resp_body, "Claws")
    end

    it "displays a link to the author's profile" do
      character = CharacterFactory.create_character(user_id: UserFactory.default_user.id)

      conn = build_conn() |> get("/c/#{character.permalink}")

      assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.profile_path(conn, :show, UserFactory.default_user))
    end
  end

  describe "index" do
    it "displays a link to create a new character" do
      conn = build_conn() |> get("/c")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.character_path(conn, :index))
    end

    it "displays links for each character regardless of creator" do
      characters = [
        CharacterFactory.create_character(name: "Frank", user_id: UserFactory.default_user.id),
        CharacterFactory.create_character(name: "Boba Fett", user_id: UserFactory.create_user!.id)
      ]

      conn = build_conn() |> get("/c")

      for character <- characters do
        assert String.contains?(conn.resp_body, character.name)
        assert String.contains?(conn.resp_body, EdgeBuilder.Router.Helpers.character_path(conn, :show, character))
      end
    end
  end

  describe "edit" do
    it "renders the character edit form" do
      character = CharacterFactory.create_character(user_id: UserFactory.default_user.id)

      character_skill = %CharacterSkill{
        base_skill_id: BaseSkill.by_name("Athletics").id,
        rank: 4,
        character_id: character.id
      } |> Repo.insert!

      talent = %Talent{
        name: "Quick Draw",
        character_id: character.id
      } |> Repo.insert!

      attack = %Attack{
        weapon_name: "Holdout Blaster",
        character_id: character.id
      } |> Repo.insert!

      force_power = %ForcePower{
        name: "Force Vuvuzela",
        character_id: character.id
      } |> Repo.insert!

      force_power_upgrade = %ForcePowerUpgrade{
        name: "Horn Volumizer",
        force_power_id: force_power.id
      } |> Repo.insert!

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/c/#{character.permalink}/edit")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, character.name)
      assert String.contains?(conn.resp_body, character_skill.rank |> to_string)
      assert String.contains?(conn.resp_body, talent.name)
      assert String.contains?(conn.resp_body, attack.weapon_name)
      assert String.contains?(conn.resp_body, force_power.name)
      assert String.contains?(conn.resp_body, force_power_upgrade.name)
    end

    it "works on characters with no children associated to them" do
      character = CharacterFactory.create_character(user_id: UserFactory.default_user.id)

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/c/#{character.permalink}/edit")

      assert conn.status == 200
      assert String.contains?(conn.resp_body, character.name)
    end

    it "requires authentication" do
      conn = build_conn() |> get("/c/123/edit")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user!(username: "other")
      character = CharacterFactory.create_character(user_id: owner.id)

      conn = build_conn() |> authenticate_as(other) |> get("/c/#{character.permalink}/edit")

      assert is_redirect_to?(conn, "/")
    end
  end

  describe "update" do
    it "updates the character's basic attributes" do
      character = CharacterFactory.create_character(name: "asdasd", species: "gogogo")

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{"name" => "Do'mesh", "species" => "Twi'lek"}})

      character = Repo.get(Character, character.id)

      assert character.name == "Do'mesh"
      assert character.species == "Twi'lek"
    end

    it "redirects to the character show page" do
      character = CharacterFactory.create_character

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{"name" => "Do'mesh", "species" => "Twi'lek"}})

      assert conn.status == 302
      assert is_redirect_to?(conn, EdgeBuilder.Router.Helpers.character_path(conn, :show, character))
    end

    it "updates the character's optional attributes" do
      character = CharacterFactory.create_character(
        xp_total: 50,
        xp_available: 10,
        description: "A slow shooter"
      )

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{
        "xp_total" => "60",
        "xp_available" => "",
        "description" =>  "tbd"
      }})

      character = Repo.get(Character, character.id)

      assert character.xp_total == 60
      assert is_nil(character.xp_available)
      assert character.description == "tbd"
      assert is_nil(character.other_notes)
    end

    it "updates the character's prior talents" do
      character = CharacterFactory.create_character

      talent = %Talent{
        name: "Quick Draw",
        book_and_page: "EotE Core p145",
        description: "Draws a gun quickly",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "talents" => %{
        "0" => %{"book_and_page" => "DC p43", "description" => "Do stuff", "id" => talent.id, "name" => "Awesome Guy"}
      }})

      [talent] = Talent.for_character(character.id)

      assert talent.name == "Awesome Guy"
      assert talent.description == "Do stuff"
      assert talent.book_and_page == "DC p43"
    end

    it "creates new talents for the character" do
      character = CharacterFactory.create_character

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "talents" => %{
        "0" => %{"book_and_page" => "DC p43", "description" => "Do stuff", "name" => "Awesome Guy"}
      }})

      [talent] = Talent.for_character(character.id)

      assert talent.name == "Awesome Guy"
      assert talent.description == "Do stuff"
      assert talent.book_and_page == "DC p43"
    end

    it "filters out empty talents from the request" do
      character = CharacterFactory.create_character

      talent = %Talent{
        name: "Quick Draw",
        book_and_page: "EotE Core p145",
        description: "Draws a gun quickly",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "talents" => %{
        "0" => %{"book_and_page" => "", "description" => "", "name" => ""},
        "1" => %{"book_and_page" => "", "description" => "", "name" => "", "id" => talent.id}
      }})

      assert [] == Talent.for_character(character.id)
    end

    it "deletes any talents for that character that were not specified in the update" do
      character = CharacterFactory.create_character

      %Talent{
        name: "Quick Draw",
        book_and_page: "EotE Core p145",
        description: "Draws a gun quickly",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}})

      talents = Talent.for_character(character.id)

      assert Enum.count(talents) == 0
      assert Repo.all(Talent) |> Enum.count == 0
    end

    it "updates the character's prior attacks" do
      character = CharacterFactory.create_character

      attack = %Attack{
        weapon_name: "Holdout Blaster",
        range: "Short",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "attacks" => %{
        "0" => %{"weapon_name" => "Claws", "range" => "Engaged", "id" => attack.id}
      }})

      [attack] = Attack.for_character(character.id)

      assert attack.weapon_name == "Claws"
      assert attack.range == "Engaged"
    end

    it "creates new attacks for the character" do
      character = CharacterFactory.create_character

      base_skill = Repo.all(BaseSkill) |> Enum.at(0)

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "attacks" => %{
        "0" => %{"weapon_name" => "Claws", "range" => "Engaged", "base_skill_id" => base_skill.id}
      }})

      [attack] = Attack.for_character(character.id)

      assert attack.weapon_name == "Claws"
      assert attack.range == "Engaged"
      assert attack.base_skill_id == base_skill.id
    end

    it "deletes any attacks for that character that were not specified in the update" do
      character = CharacterFactory.create_character

      %Attack{
        weapon_name: "Holdout Blaster",
        range: "Short",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}})

      attacks = Attack.for_character(character.id)

      assert Enum.count(attacks) == 0
      assert Repo.all(Attack) |> Enum.count == 0
    end

    it "creates new skills when they differ from default values" do
      character = CharacterFactory.create_character

      base_skill = BaseSkill.by_name("Athletics")

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 1, "is_career" => "on"}}})

      [character_skill] = CharacterSkill.for_character(character.id)

      assert character_skill.rank == 1
      assert character_skill.is_career
      assert character_skill.base_skill_id == base_skill.id
    end

    it "does not create new skills for skills that are not persisted and that do not differ from defaults" do
      character = CharacterFactory.create_character

      base_skill = BaseSkill.by_name("Athletics")

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 0}}})

      assert Enum.count(CharacterSkill.for_character(character.id)) == 0
    end

    it "deletes previously-saved skills that are set back to the default" do
      character = CharacterFactory.create_character

      base_skill = BaseSkill.by_name("Athletics")

      original_character_skill = %CharacterSkill{
        base_skill_id: base_skill.id,
        character_id: character.id,
        rank: 5
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "skills" => %{"0" => %{"base_skill_id" => base_skill.id, "rank" => 0, "id" => original_character_skill.id}}})

      assert [] == CharacterSkill.for_character(character.id)
    end

    it "re-renders the edit character page when there are errors" do
      character = CharacterFactory.create_character

      base_skill = BaseSkill.by_name("Astrogation")

      %CharacterSkill{
        base_skill_id: base_skill.id,
        character_id: character.id,
        rank: 5
      } |> Repo.insert!

      conn = build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{
        "character" => %{
          "name" => "",
          "species" => "Rodian",
          "career" => "Bounty Hunter"
        },
        "skills" => %{"0" => %{"base_skill_id" => BaseSkill.by_name("Athletics").id, "rank" => "3", "is_career" => "on"}}
      })

      assert FlokiExt.element(conn, ".alert-danger") |> FlokiExt.text == "Name can't be blank"
      assert FlokiExt.element(conn, "[data-skill=Athletics]") |> FlokiExt.find("input[type=text]") |> FlokiExt.attribute("value") == "3"
      assert !is_nil(FlokiExt.element(conn, ".attack-first-row"))
      assert !is_nil(FlokiExt.element(conn, ".talent-row"))
    end

    it "updates the character's prior force powers" do
      character = CharacterFactory.create_character

      force_power = %ForcePower{
        name: "Sandwich Artistry",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "force_powers" => %{
        "0" => %{"name" => "Hot Doggin'", "description" => "Do funny stuff on holonet terminals when unlocked", "id" => force_power.id, "display_order" => "0"}
      }})

      [force_power] = ForcePower.for_character(character.id)

      assert force_power.name == "Hot Doggin'"
      assert force_power.description == "Do funny stuff on holonet terminals when unlocked"
    end

    it "creates new force powers for the character" do
      character = CharacterFactory.create_character

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "force_powers" => %{
        "0" => %{"name" => "Sandwich Artistry", "description" => "Make great sandwiches"}
      }})

      [force_power] = ForcePower.for_character(character.id)

      assert force_power.name == "Sandwich Artistry"
      assert force_power.description == "Make great sandwiches"
    end

    it "filters out empty force powers from the request" do
      character = CharacterFactory.create_character

      force_power = %ForcePower{
        name: "Sandwich Artistry",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "force_powers" => %{
        "0" => %{"description" => "", "name" => ""},
        "1" => %{"description" => "", "name" => "", "id" => force_power.id}
      }})

      assert [] == ForcePower.for_character(character.id)
    end

    it "deletes any force powers for that character that were not specified in the update" do
      character = CharacterFactory.create_character

      %ForcePower{
        name: "Sandwich Artistry",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}})

      force_powers = ForcePower.for_character(character.id)

      assert Enum.count(force_powers) == 0
      assert Repo.all(ForcePower) |> Enum.count == 0
    end

    it "updates the character's prior force power upgrades" do
      character = CharacterFactory.create_character

      force_power = %ForcePower{
        name: "Sandwich Artistry",
        character_id: character.id
      } |> Repo.insert!

      force_power_upgrade = %ForcePowerUpgrade{
        name: "Double Meat",
        force_power_id: force_power.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "force_powers" => %{
        "0" => %{"id" => force_power.id, "force_power_upgrades" => %{"0" => %{"name" => "Upselling", "description" => "Add boost die to attempts to upsell sandwich addons", "id" => force_power_upgrade.id}}}
      }})

      force_power_upgrade = Repo.get(ForcePowerUpgrade, force_power_upgrade.id)

      assert force_power_upgrade.name == "Upselling"
      assert force_power_upgrade.description == "Add boost die to attempts to upsell sandwich addons"
    end

    it "creates new force power upgrades for the character" do
      character = CharacterFactory.create_character

      force_power = %ForcePower{
        name: "Sandwich Artistry",
        character_id: character.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "force_powers" => %{
        "0" => %{"id" => force_power.id, "force_power_upgrades" => %{"0" => %{"name" => "Upselling", "description" => "Add boost die to attempts to upsell sandwich addons"}}}
      }})

      [force_power] = ForcePower.for_character(character.id)
      [force_power_upgrade] = force_power.force_power_upgrades

      assert force_power_upgrade.name == "Upselling"
      assert force_power_upgrade.description == "Add boost die to attempts to upsell sandwich addons"
    end

    it "filters out empty force power upgrades from the request" do
      character = CharacterFactory.create_character

      force_power = %ForcePower{
        name: "Sandwich Artistry",
        character_id: character.id
      } |> Repo.insert!

      force_power_upgrade = %ForcePowerUpgrade{
        name: "Double Meat",
        force_power_id: force_power.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "force_powers" => %{
        "0" => %{"id" => force_power.id, "force_power_upgrades" => %{
            "0" => %{"name" => "", "description" => ""},
            "1" => %{"name" => "", "description" => "", "id" => force_power_upgrade.id}
        }}
      }})

      [force_power] = ForcePower.for_character(character.id)

      assert [] == force_power.force_power_upgrades
    end

    it "deletes any force power upgrades for that character that were not specified in the update" do
      character = CharacterFactory.create_character

      force_power = %ForcePower{
        name: "Sandwich Artistry",
        character_id: character.id
      } |> Repo.insert!

      %ForcePowerUpgrade{
        name: "Double Meat",
        force_power_id: force_power.id
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> put("/c/#{character.permalink}", %{"character" => %{}, "force_powers" => %{
        "0" => %{"id" => force_power.id, "name" => "foo"}
      }})

      [force_power] = ForcePower.for_character(character.id)

      assert [] == force_power.force_power_upgrades
    end

    it "requires authentication" do
      conn = build_conn() |> put("/c/123")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user!(username: "other")
      character = CharacterFactory.create_character(user_id: owner.id)

      conn = build_conn() |> authenticate_as(other) |> put("/c/#{character.permalink}", %{"character" => %{}})

      assert is_redirect_to?(conn, "/")
    end
  end

  describe "delete" do
    it "deletes a character and all associated records" do
      character = CharacterFactory.create_character

      base_skill = BaseSkill.by_name("Astrogation")

      %CharacterSkill{
        base_skill_id: base_skill.id,
        character_id: character.id,
        rank: 5
      } |> Repo.insert!

      build_conn() |> authenticate_as(UserFactory.default_user) |> delete("/c/#{character.permalink}")

      assert is_nil(Repo.get(Character, character.id))
      assert is_nil(Repo.one(from cs in CharacterSkill, where: cs.character_id == ^(character.id)))
    end

    it "requires authentication" do
      conn = build_conn() |> delete("/c/123")

      assert requires_authentication?(conn)
    end

    it "requires the current user to match the owning user" do
      owner = UserFactory.default_user
      other = UserFactory.create_user!(username: "other")
      character = CharacterFactory.create_character(user_id: owner.id)

      conn = build_conn() |> authenticate_as(other) |> delete("/c/#{character.permalink}")

      assert is_redirect_to?(conn, "/")
    end
  end
  
  it "updates current wounds" do
    character = CharacterFactory.create_character(user_id: UserFactory.default_user.id)

    conn = build_conn() |> authenticate_as(UserFactory.default_user) |> get("/c/#{character.permalink}")

    assert String.contains?(conn.resp_body, "Edit")
    assert String.contains?(conn.resp_body, "Delete")
  end
end
