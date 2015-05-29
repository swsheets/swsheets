defmodule EdgeBuilder.Models.Characteristic do
  @shorthands %{
    "Agility"   => "Ag",
    "Brawn"     => "Br",
    "Cunning"   => "Cun",
    "Intellect" => "Int",
    "Presence"  => "Pr",
    "Willpower" => "Will",
  }

  def shorthand_for(characteristic) do
    @shorthands[characteristic]
  end
end
