var CharacterForm = (function() {
  var characteristicsToSkills = {
    "Brawn"     : ["Brawl", "Melee", "Athletics", "Resilience"],
    "Agility"   : ["Ranged: Light", "Ranged: Heavy", "Gunnery", "Coordination", "Piloting: Planetary", "Piloting: Space", "Stealth"],
    "Intellect" : ["Astrogation", "Computers", "Mechanics", "Medicine", "Knowledge: Core Worlds", "Knowledge: Education", "Knowledge: Lore", "Knowledge: Outer Rim", "Knowledge: Underworld", "Knowledge: Xenology"],
    "Cunning"   : ["Perception", "Deception", "Skulduggery", "Streetwise", "Survival"],
    "Willpower" : ["Discipline", "Vigilance", "Coercion"],
    "Presence"  : ["Cool", "Negotiation", "Leadership", "Charm"]
  };

  function setDiceForSkill(skillName, abilities, proficiencies) {
    $("[data-skill-roll='"+skillName+"']").each( function() {
      $(this).empty();

      for(var i = 0; i < proficiencies; i++) {
        $(this).append($("#dieProficiency").clone().show());
      }

      for(var i = 0; i < abilities; i++) {
        $(this).append($("#dieAbility").clone().show());
      }
    });
  }

  function refreshSkillByName(skillName) {
    var skillElement = $("[data-skill-name='"+skillName+"']");
    var valueElement = $("[data-skill-value='"+skillName+"']:checked");
    var skillRank = valueElement.prop("value");
    var characteristicRank = $("#"+skillElement.attr("data-base-characteristic")).prop("value");

    var abilities = Math.min(skillRank, characteristicRank);
    var proficiencies = Math.max(skillRank, characteristicRank) - abilities;

    setDiceForSkill(skillName, abilities, proficiencies);
  }

  function refreshSkillsFromCharacteristic(characteristicElement) {
    $("[data-base-characteristic="+characteristicElement.prop("id")+"]").each(function() {
      refreshSkillByName($(this).attr("data-skill-name"));
    });
  }

  function initializeHandlers() {
    $("[data-skill-value]:radio").change(function() { refreshSkillByName($(this).attr("data-skill-value")) });
    $("[data-characteristic]").change(function() { refreshSkillsFromCharacteristic($(this)) });
  }

  function refreshAllDice() {
    $("[data-characteristic]").change();
  }

  return {
    init: function() {
      initializeHandlers();
      refreshAllDice();
    }
  };
})();

$(CharacterForm.init);
