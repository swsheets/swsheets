defmodule EdgeBuilder.Models.BaseSkillTest do
  use EdgeBuilder.ModelCase

  alias EdgeBuilder.Models.BaseSkill

  describe "all" do
    it "orders by skill position" do
      %BaseSkill{name: "Foosball", characteristic: "Agility", display_order: -1} |> EdgeBuilder.Repo.insert!

      [skill | _] = BaseSkill.all

      assert skill.name == "Foosball"
    end
  end

  describe "by_name" do
    it "retrieves a base skill by name" do
      skill = BaseSkill.by_name("Athletics")

      assert skill.name == "Athletics"
      assert skill.characteristics == ["Brawn"]
    end
  end

  describe "attack skills" do
    it "retrieves attack skills in display order" do
      skills = BaseSkill.attack_skills |> Enum.map(&(Map.take(&1, [:name, :characteristics])))

      assert skills == [
        %{name: "Brawl", characteristics: ["Brawn"]},
        %{name: "Gunnery", characteristics: ["Agility"]},
        %{name: "Lightsaber", characteristics: ["Brawn", "Agility", "Intellect", "Cunning", "Willpower", "Presence"]},
        %{name: "Melee", characteristics: ["Brawn"]},
        %{name: "Ranged: Light", characteristics: ["Agility"]},
        %{name: "Ranged: Heavy", characteristics: ["Agility"]},
      ]
    end
  end
end
