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

  function refreshRollsBySkillName(skillName) {
    var skillElement = $("[data-skill='"+skillName+"']");
    refreshRollsFromSkill(skillElement.find("[data-rank]"));
  }

  function refreshRollsFromSkill(skillRankElement) {
    var skillRank = skillRankElement.val();
    var skillElement = skillRankElement.closest("[data-skill]");
    var characteristicRank = $("#"+skillElement.find("[data-selected-characteristic]").val()).val();

    var abilities = Math.min(skillRank, characteristicRank);
    var proficiencies = Math.max(skillRank, characteristicRank) - abilities;

    setDiceForSkill(skillElement.attr("data-skill"), abilities, proficiencies);
  }

  function refreshRollsFromCharacteristic(characteristicElement) {
    $("[data-selected-characteristic][value="+characteristicElement.prop("id")+"]").each(function() {
      var skillElement = $(this).closest("[data-skill]");
      refreshRollsBySkillName(skillElement.attr("data-skill"));
    });
  }

  function switchAttackRollFromSelection(skillSelectElement) {
    var attackIndex = skillSelectElement.attr("data-attack-index");
    var skillName = $(skillSelectElement).find('option:selected').text();
    $("[data-attack-roll-index="+attackIndex+"]").attr("data-skill-roll", skillName);
    refreshRollsBySkillName(skillName);
  }

  function addTalent() {
    var talentRow = $(".talent-row:last").clone(true);
    var previousIndex = parseInt(talentRow.attr("data-talent"));
    var index = previousIndex + 1;
    var talentTable = $("#talentTable");

    talentTable.append(talentRow);

    talentRow.attr("data-talent", index);
    talentRow.find("[type=text]").val("");
    talentRow.find("[name]").attr("name", function(i, currentName) { return currentName.replace("talents["+previousIndex+"]", "talents["+index+"]") });
    talentRow.find("[for]").attr("for", function(i, currentFor) { return currentFor.replace("talents["+previousIndex+"]", "talents["+index+"]") });
    talentRow.find("[name='talents["+index+"][id]']").remove();
    talentRow.find("[name='talents["+index+"][display_order]']").val(index);
    talentRow.find("[data-remove-talent]").attr("data-remove-talent", index);

    enableDisableRemoveTalentButtons();
  }

  function enableDisableRemoveTalentButtons() {
    var removeButtons = $("[data-remove-talent]");
    if(removeButtons.length == 1) {
      removeButtons.attr("disabled", "disabled");
    } else {
      removeButtons.removeAttr("disabled");
    }
  }

  function removeTalent(talentIndex) {
    $("[data-talent="+talentIndex+"]").remove();

    enableDisableRemoveTalentButtons();
  }

  function addForcePower() {
    var lastRow = $(".force-power-row:last");
    var newRow = lastRow.clone(true);
    var previousIndex = parseInt(newRow.attr("data-force-power"));
    var index = previousIndex + 1;
    newRow.insertAfter(lastRow);

    newRow.toggleClass("active");
    newRow.attr("data-force-power", index);
    newRow.find("[type=text]").val("");
    newRow.find("textarea").val("");
    newRow.find("[name]").attr("name", function(i, currentName) { return currentName.replace("force_powers["+previousIndex+"]", "force_powers["+index+"]") });
    newRow.find("[for]").attr("for", function(i, currentFor) { return currentFor.replace("force_powers["+previousIndex+"]", "force_powers["+index+"]") });
    newRow.find("[name$='[id]']").remove();
    newRow.find("[name='force_powers["+index+"][display_order]']").val(index);
    newRow.find("[data-remove-force-power]").attr("data-remove-force-power", index);
    newRow.find("[data-force-power-add-upgrade]").attr("data-force-power-add-upgrade", index);
    newRow.find("[data-parent-force-power]").attr("data-parent-force-power", index);

    var upgradeCount = 0;
    newRow.find("[data-force-power-upgrade]").each(function() {
      if(upgradeCount > 0) {
        $(this).remove();
      }
      upgradeCount++;
    });

    enableDisableRemoveForcePowerButtons();
  }

  function removeForcePower(index) {
    $("[data-force-power="+index+"]").remove();

    $(".force-power-row").each(function(i) {
      if(i % 2 == 0) {
        $(this).addClass("active");
      } else {
        $(this).removeClass("active");
      }
    });

    enableDisableRemoveForcePowerButtons();
  }

  function enableDisableRemoveForcePowerButtons() {
    var removeButtons = $("[data-remove-force-power]");

    if(removeButtons.length == 1) {
      removeButtons.attr("disabled", "disabled");
    } else {
      removeButtons.removeAttr("disabled");
    }
  }

  function addForcePowerUpgrade(forcePowerIndex) {
    var lastRow = $("[data-force-power="+forcePowerIndex+"] [data-force-power-upgrade]:last");
    var newRow = lastRow.clone(true);
    var previousIndex = parseInt(newRow.attr("data-force-power-upgrade"));
    var index = previousIndex + 1;
    newRow.insertAfter(lastRow);

    newRow.attr("data-force-power-upgrade", index);
    newRow.find("[type=text]").val("");
    newRow.find("textarea").val("");
    newRow.find("[name]").attr("name", function(i, currentName) { return currentName.replace("[force_power_upgrades]["+previousIndex+"]", "[force_power_upgrades]["+index+"]") });
    newRow.find("[for]").attr("for", function(i, currentFor) { return currentFor.replace("[force_power_upgrades]["+previousIndex+"]", "[force_power_upgrades]["+index+"]") });
    newRow.find("[name='force_powers["+forcePowerIndex+"][force_power_upgrades]["+index+"][id]']").remove();
    newRow.find("[name='force_powers["+forcePowerIndex+"][force_power_upgrades]["+index+"][display_order]']").val(index);
    newRow.find("[data-remove-force-power-upgrade]").attr("data-remove-force-power-upgrade", index);

    enableDisableRemoveForcePowerUpgradeButtons(forcePowerIndex);
  }

  function removeForcePowerUpgrade(forcePowerIndex, forceUpgradeIndex) {
    var forcePower = $("[data-force-power="+forcePowerIndex+"]");
    forcePower.find("[data-force-power-upgrade="+forceUpgradeIndex+"]").remove();

    enableDisableRemoveForcePowerUpgradeButtons(forcePowerIndex);
  }

  function enableDisableRemoveForcePowerUpgradeButtons(forcePowerIndex) {
    var removeButtons = $("[data-force-power="+forcePowerIndex+"] [data-remove-force-power-upgrade]");

    if(removeButtons.length == 1) {
      removeButtons.attr("disabled", "disabled");
    } else {
      removeButtons.removeAttr("disabled");
    }
  }

  function enableDisableRemoveAllForcePowerUpgradeButtons() {
    $("[data-force-power]").each(function() {
      enableDisableRemoveForcePowerUpgradeButtons($(this).attr("data-force-power"));
    });
  }

  function addAttack() {
    var firstAttackRow = $(".attack-first-row:last").clone(true);
    var secondAttackRow = $(".attack-second-row:last").clone(true);
    var previousIndex = parseInt(firstAttackRow.attr("data-attack"));
    var index = previousIndex + 1;
    var attackTable = $("#attackTable");

    $.each([firstAttackRow, secondAttackRow], function(_, row) {
      attackTable.append(row);

      row
        .attr("data-attack", index)
        .toggleClass("active");

      row.find("[type=text]").val("");
      row.find("[name]").attr("name", function(i, currentName) { return currentName.replace("attacks["+previousIndex+"]", "attacks["+index+"]") });
      row.find("[for]").attr("for", function(i, currentFor) { return currentFor.replace("attacks["+previousIndex+"]", "attacks["+index+"]") });
    });

    firstAttackRow.find("[name='attacks["+index+"][id]']").remove();
    firstAttackRow.find("[name='attacks["+index+"][display_order]']").val(index);
    firstAttackRow.find("[data-attack-roll-index]").attr("data-attack-roll-index", index);
    firstAttackRow.find("[data-attack-index]").attr("data-attack-index", index);
    firstAttackRow.find("select").val(function() { return $(this).find("option:first").val() }).change();
    secondAttackRow.find("[data-remove-attack]").attr("data-remove-attack", index);

    enableDisableRemoveAttackButtons();
  }

  function enableDisableRemoveAttackButtons() {
    var removeButtons = $("[data-remove-attack]");
    if(removeButtons.length == 1) {
      removeButtons.attr("disabled", "disabled");
    } else {
      removeButtons.removeAttr("disabled");
    }
  }

  function removeAttack(attackIndex) {
    $("[data-attack="+attackIndex+"]").remove();

    $.each([".attack-first-row", ".attack-second-row"], function(i, selector) {
      var i = 0;

      $(selector).each( function() {
        if(i % 2 == 0) {
          $(this).addClass("active");
        } else {
          $(this).removeClass("active");
        }
        i++;
      });
    });

    enableDisableRemoveAttackButtons();
  }

  function setSystem(system) {
    $("#systemButton").empty();
    $("[data-value="+system+"]").contents().clone().appendTo("#systemButton");
    $("#systemValue").val(system).change();

    $("[data-system]").each(function() {
      if( $(this).attr("data-system") == system && $(this).attr("data-skill-hidden") === undefined) {
        $(this).show();
      } else {
        $(this).hide();
      }
    });
  }

  function setSystemOrDefault() {
    var system = $("#systemValue").val() || "eote";
    setSystem(system);
  }

  function advanceSkill(skillName, increment) {
    var skill = $("[data-skill='"+skillName+"']");
    var currentCharacteristic = skill.find("[data-selected-characteristic]").val();
    var availableCharacteristics = skill.find("[data-available-characteristic]");
    var characteristicCount = availableCharacteristics.size();
    var selectedIndex = 0;

    availableCharacteristics.each(function(i) {
      if($(this).val() == currentCharacteristic) {
        selectedIndex = i;
      }
    });

    var currentCharacteristicElement = availableCharacteristics.eq(selectedIndex);

    selectedIndex += increment;

    if(selectedIndex >= characteristicCount) {
      selectedIndex -= characteristicCount;
    }

    var selectedCharacteristic = availableCharacteristics.eq(selectedIndex);

    skill.find("[data-selected-characteristic]").val(selectedCharacteristic.val());
    skill.find("[data-skill-full-name]").text(skillName + " (" + selectedCharacteristic.attr("data-shorthand") + ")");

    refreshRollsBySkillName(skillName);
  }

  function initializeHandlers() {
    $("[data-rank]").change(function() { refreshRollsFromSkill($(this)) });
    $("[data-characteristic]").change(function() { refreshRollsFromCharacteristic($(this)) });
    $("[data-attack-skill]").change(function() { switchAttackRollFromSelection($(this)) });
    $("#addAttackButton").click(addAttack);
    $("[data-remove-attack]").click(function() { removeAttack($(this).attr("data-remove-attack")) });
    $("[data-remove-talent]").click(function() { removeTalent($(this).attr("data-remove-talent")) });
    $("[data-remove-force-power]").click(function() { removeForcePower($(this).attr("data-remove-force-power")) });
    $("[data-remove-force-power-upgrade]").click(function() { removeForcePowerUpgrade($(this).attr("data-parent-force-power"), $(this).attr("data-remove-force-power-upgrade")) });
    $("#addOneTalentButton").click(addTalent);
    $("#addFiveTalentsButton").click(function() { for(var i = 0; i < 5; i++) { addTalent() } });
    $("#addForcePowerButton").click(addForcePower);
    $("[data-force-power-add-upgrade]").click(function() { addForcePowerUpgrade($(this).attr("data-force-power-add-upgrade")) });
    $("#systemButton").click(function() { $("#systemDropdown").dropdown('toggle'); return false; });
    $(".select-button a").click(function() { setSystem($(this).attr('data-value')); });
    $("[data-skill-previous]").click(function(e) { e.preventDefault(); advanceSkill($(this).attr('data-skill-previous'), -1); });
    $("[data-skill-next]").click(function(e) { e.preventDefault(); advanceSkill($(this).attr('data-skill-next'), 1); });
  }

  function refreshAllDice() {
    $("[data-attack-skill]").change();
    $("[data-characteristic]").change();
  }

  function hideHiddenSkills() {
    $("[data-skill-hidden]").hide();
  }

  function initializeIncrementers() {
    $("#incrementWounds").click(function() {
      incrementWounds(1);
    });
    $("#decrementWounds").click(function() {
      incrementWounds(-1);
    });
    $("#incrementStrain").click(function() {
      incrementStrain(1);
    });
    $("#decrementStrain").click(function() {
      incrementStrain(-1);
    });
  }

  function incrementWounds(num) {
    incrementValue("wounds_current", $("#currentWounds"), num);
  }

  function incrementStrain(num) {
    incrementValue("strain_current", $("#currentStrain"), num);
  }

  function incrementValue(key, $el, num) {
    var current = parseInt($el.text(), 10),
        updated = current + num,
        characterId = window.location.pathname.match(/^\/c\/(.+)$/)[1],
        data = {character: {}};
    data.character[key] = updated;
    $el.text("" + updated);
    $.ajax({
      method: "PUT",
      url: "/api/characters/" + characterId,
      data: JSON.stringify(data),
      dataType: "json",
      contentType: "application/json"
    });

  var careersBySystem = {
    eote: [
      {
        name: "Bounty Hunter",
        specializations: ["Assassin", "Gadgeteer", "Survivalist"]
      },
      {
        name: "Colonist",
        specializations: ["Doctor", "Politico", "Scholar", "Entrepreneur", "Performer", "Marshall"]
      },
      {
        name: "Explorer",
        specializations: ["Fringer", "Scout", "Trader", "Archaeologist", "Big-Game Hunter", "Driver"]
      },
      {
        name: "Hired Gun",
        specializations: ["Bodyguard", "Marauder", "Mercenary Soldier", "Enforcer", "Demolitionist", "Heavy"]
      },
      {
        name: "Smuggler",
        specializations: ["Pilot", "Scoundrel", "Thief", "Technician", "Mechanic", "Outlaw Tech", "Slicer"]
      }
    ],
    aor: [
      {
        name: "Ace",
        specializations: ["Driver", "Gunner", "Pilot"]
      },
      {
        name: "Commander",
        specializations: ["Commodore", "Squad Leader", "Tactician"]
      },
      {
        name: "Diplomat",
        specializations: ["Ambassador", "Agitator", "Quartermaster"]
      },
      {
        name: "Engineer",
        specializations: ["Mechanic", "Saboteur", "Scientist"]
      },
      {
        name: "Soldier",
        specializations: ["Commando", "Medic", "Sharpshooter"]
      },
      {
        name: "Spy",
        specializations: ["Infiltrator", "Scout", "Slicer"]
      }
    ]

  var systemData = {
    eote: {
      species: [
        "Aqualish (Aquala)", "Aqualish (Quara)", "Aqualish (Ualaq)",
        "Arcona", "Bothan", "Chevin", "Chiss", "Drall",
        "Droid", "Duros", "Gand", "Gank", "Human", "Human (Corellian)",
        "Hutt", "Klatooinian", "Rodian", "Selonian", "Toydarian",
        "Twi'lek", "Weequay", "Wookiee"
      ],
      careers: [
        {
          name: "Bounty Hunter",
          specializations: ["Assassin", "Gadgeteer", "Survivalist"]
        },
        {
          name: "Colonist",
          specializations: ["Doctor", "Politico", "Scholar", "Entrepreneur", "Performer", "Marshall"]
        },
        {
          name: "Explorer",
          specializations: ["Fringer", "Scout", "Trader", "Archaeologist", "Big-Game Hunter", "Driver"]
        },
        {
          name: "Hired Gun",
          specializations: ["Bodyguard", "Marauder", "Mercenary Soldier", "Enforcer", "Demolitionist", "Heavy"]
        },
        {
          name: "Smuggler",
          specializations: ["Pilot", "Scoundrel", "Thief", "Technician", "Mechanic", "Outlaw Tech", "Slicer"]
        }
      ]
    },
    aor: {
      species: [
        "Caamasi", "Chadra-Fan", "Dressellian", "Droid",
        "Duros", "Gossam", "Gran", "Human", "Ithorian",
        "Mon Calamari", "Neimoidian", "Sullustan", "Xexto"
      ],
      careers: [
        {
          name: "Ace",
          specializations: ["Driver", "Gunner", "Pilot"]
        },
        {
          name: "Commander",
          specializations: ["Commodore", "Squad Leader", "Tactician"]
        },
        {
          name: "Diplomat",
          specializations: ["Ambassador", "Agitator", "Quartermaster"]
        },
        {
          name: "Engineer",
          specializations: ["Mechanic", "Saboteur", "Scientist"]
        },
        {
          name: "Soldier",
          specializations: ["Commando", "Medic", "Sharpshooter"]
        },
        {
          name: "Spy",
          specializations: ["Infiltrator", "Scout", "Slicer"]
        }
      ]
    }
  };

  var $careerSelect, $speciesSelect;

  function initializeCareer() {
    var $origField = $("#character-career");
    if (!$origField[0]) return;
    $careerSelect = selectizeInput($origField, careerNames());
    $("#systemValue").change(function() {
      updateSelectOptions($careerSelect, careerNames());
    });
  }

  function initializeSpecies() {
    var $origField = $("#character-species");
    if (!$origField[0]) return;
    $speciesSelect = selectizeInput($origField, speciesNames());
    $("#systemValue").change(function() {
      updateSelectOptions($speciesSelect, speciesNames());
    });
  }

  function careerNames() {
    var system = $("#systemValue").val(),
        careers = systemData[system].careers;
    return careers.map(function(c) { return c.name; });
  }

  function speciesNames() {
    var system = $("#systemValue").val();
    return systemData[system].species;
  }

  function selectizeInput($input, options) {
    var $select = $("<select></select>"),
        value = $input.val(),
        name = $input.attr("name"),
        classes = $input.attr("class");
    updateSelectOptions($select, options, value);
    $select.val(value);
    $select.attr("class", classes);
    $select.change(function() {
      var val = $select.val();
      if (val === "_") {
        $input.val("");
        $input.show();
        $select.remove();
      } else {
        $input.val(val);
      }
    });
    $input.before($select);
    $input.hide();
    return $select;
  }

  function updateSelectOptions($select, arrayOfStrings, origVal) {
    origVal = origVal || $select.val();
    $select.empty();
    $select.append("<option value='_'>Create Your Own</option>");
    if (arrayOfStrings.indexOf(origVal) === -1) {
      arrayOfStrings.unshift(origVal);
    }
    for(var i=0; i < arrayOfStrings.length; i++) {
      var str = arrayOfStrings[i];
      $select.append("<option value='"+str+"'>"+str+"</option>");
    }
    $select.val(origVal);
  }

  return {
    init: function() {
      initializeHandlers();
      refreshAllDice();
      enableDisableRemoveAttackButtons();
      enableDisableRemoveTalentButtons();
      enableDisableRemoveForcePowerButtons();
      enableDisableRemoveAllForcePowerUpgradeButtons();
      hideHiddenSkills();
      setSystemOrDefault();
      initializeIncrementers();
      initializeCareer();
      initializeSpecies();
    }
  };
})();

$(CharacterForm.init);
