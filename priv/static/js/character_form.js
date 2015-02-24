var CharacterForm = (function() {
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
    var skillRank = valueElement.val();
    var characteristicRank = $("#"+skillElement.attr("data-base-characteristic")).val();

    var abilities = Math.min(skillRank, characteristicRank);
    var proficiencies = Math.max(skillRank, characteristicRank) - abilities;

    setDiceForSkill(skillName, abilities, proficiencies);
  }

  function refreshSkillsFromCharacteristic(characteristicElement) {
    $("[data-base-characteristic="+characteristicElement.prop("id")+"]").each(function() {
      refreshSkillByName($(this).attr("data-skill-name"));
    });
  }

  function switchAttackRollFromSelection(skillSelectElement) {
    var attackIndex = skillSelectElement.attr("data-attack-index");
    var skillName = $(skillSelectElement).find('option:selected').text();
    $("[data-attack-roll-index="+attackIndex+"]").attr("data-skill-roll", skillName);
    refreshSkillByName(skillName);
  }

  function initializeHandlers() {
    $("[data-skill-value]").change(function() { refreshSkillByName($(this).attr("data-skill-value")) });
    $("[data-characteristic]").change(function() { refreshSkillsFromCharacteristic($(this)) });
    $("[data-attack-skill]").change(function() { switchAttackRollFromSelection($(this)) });
  }

  function refreshAllDice() {
    $("[data-attack-skill]").change();
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
