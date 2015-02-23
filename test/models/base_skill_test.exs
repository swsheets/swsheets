defmodule EdgeBuilder.Models.BaseSkillTest do
  use EdgeBuilder.Test

  alias EdgeBuilder.Models.BaseSkill

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
