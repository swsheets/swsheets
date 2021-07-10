defmodule EdgeBuilder.Models.BaseSkillTest do
  use EdgeBuilder.ModelCase

  alias EdgeBuilder.Models.BaseSkill

  describe "all" do
    it "orders by skill position" do
      %BaseSkill{name: "Foosball", characteristic: "Agility", display_order: -1}
      |> EdgeBuilder.Repo.insert!()

      [skill | _] = BaseSkill.all()

      assert skill.name == "Foosball"
    end
  end

  describe "by_name" do
    it "retrieves a base skill by name" do
      skill = BaseSkill.by_name("Athletics")

      assert skill.name == "Athletics"
      assert skill.characteristics == ["Brawn"]
    end

    it "returns mutiple characteristics for skills that have them" do
      charm = BaseSkill.by_name("Charm")
      assert charm.name == "Charm"
      assert charm.characteristics == ["Presence", "Cunning"]

      lightsaber = BaseSkill.by_name("Lightsaber")
      assert lightsaber.name == "Lightsaber"

      assert lightsaber.characteristics == [
               "Brawn",
               "Agility",
               "Intellect",
               "Cunning",
               "Willpower",
               "Presence"
             ]

      negotiation = BaseSkill.by_name("Negotiation")
      assert negotiation.name == "Negotiation"
      assert negotiation.characteristics == ["Presence", "Cunning"]

      streetwise = BaseSkill.by_name("Streetwise")
      assert streetwise.name == "Streetwise"
      assert streetwise.characteristics == ["Cunning", "Intellect"]

      survival = BaseSkill.by_name("Survival")
      assert survival.name == "Survival"
      assert survival.characteristics == ["Cunning", "Intellect"]
    end
  end

  describe "attack skills" do
    it "retrieves attack skills in display order" do
      skills = BaseSkill.attack_skills() |> Enum.map(&Map.take(&1, [:name, :characteristics]))

      assert skills == [
               %{name: "Brawl", characteristics: ["Brawn"]},
               %{name: "Gunnery", characteristics: ["Agility"]},
               %{
                 name: "Lightsaber",
                 characteristics: [
                   "Brawn",
                   "Agility",
                   "Intellect",
                   "Cunning",
                   "Willpower",
                   "Presence"
                 ]
               },
               %{name: "Melee", characteristics: ["Brawn"]},
               %{name: "Ranged: Light", characteristics: ["Agility"]},
               %{name: "Ranged: Heavy", characteristics: ["Agility"]}
             ]
    end
  end
end
