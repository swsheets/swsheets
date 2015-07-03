defmodule EdgeBuilder.Models.BaseSkillTest do
  use EdgeBuilder.TestCase

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
      assert skill.characteristic == "Brawn"
    end
  end

  describe "attack skills" do
    it "retrieves attack skills in display order" do
      skills = BaseSkill.attack_skills |> Enum.map(&(Map.take(&1, [:name, :characteristic])))

      assert skills == [
        %{name: "Brawl", characteristic: "Brawn"},
        %{name: "Gunnery", characteristic: "Agility"},
        %{name: "Melee", characteristic: "Brawn"},
        %{name: "Ranged: Light", characteristic: "Agility"},
        %{name: "Ranged: Heavy", characteristic: "Agility"},
      ]
    end
  end
end
