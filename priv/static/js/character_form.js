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

  function addAttack() {
    var firstAttackRow = $(".attack-first-row:last").clone(true);
    var secondAttackRow = $(".attack-second-row:last").clone(true);
    var previousIndex = parseInt(firstAttackRow.attr("data-attack"));
    var index = previousIndex + 1;
    var attackTable = $("#attackTable");

    attackTable.append(firstAttackRow);
    attackTable.append(secondAttackRow);

    firstAttackRow.find("[type=hidden]").remove();
    firstAttackRow.find("[type=text]").val("");
    firstAttackRow.attr("data-attack", index);
    firstAttackRow.find("[data-attack-roll-index]").attr("data-attack-roll-index", index);
    firstAttackRow.find("[data-attack-index]").attr("data-attack-index", index);
    firstAttackRow.find("select").val(function() { return $(this).find("option:first").val() }).change();
    firstAttackRow.toggleClass("active");
    firstAttackRow.find("[name]").attr("name", function(i, currentName) { return currentName.replace("attacks["+previousIndex+"]", "attacks["+index+"]") });
    firstAttackRow.find("[for]").attr("for", function(i, currentFor) { return currentFor.replace("attacks["+previousIndex+"]", "attacks["+index+"]") });

    secondAttackRow.find("[type=text]").val("");
    secondAttackRow.attr("data-attack", index);
    secondAttackRow.toggleClass("active");
    secondAttackRow.find("[name]").attr("name", function(i, currentName) { return currentName.replace("attacks["+previousIndex+"]", "attacks["+index+"]") });
    secondAttackRow.find("[for]").attr("for", function(i, currentFor) { return currentFor.replace("attacks["+previousIndex+"]", "attacks["+index+"]") });
  }

  function initializeHandlers() {
    $("[data-skill-value]").change(function() { refreshSkillByName($(this).attr("data-skill-value")) });
    $("[data-characteristic]").change(function() { refreshSkillsFromCharacteristic($(this)) });
    $("[data-attack-skill]").change(function() { switchAttackRollFromSelection($(this)) });
    $("#addAttackButton").click(addAttack);
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
