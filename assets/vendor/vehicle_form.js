var VehicleForm = (function() {
  function addAttachment() {
    var firstAttachmentRow = $(".attachment.child-first-row:last").clone(true);
    var secondAttachmentRow = $(".attachment.child-second-row:last").clone(true);
    var previousIndex = parseInt(firstAttachmentRow.attr("data-attachment"));
    var index = previousIndex + 1;
    var attachmentTable = $(".attachment.child-table");

    $.each([firstAttachmentRow, secondAttachmentRow], function(_, row) {
      attachmentTable.append(row);

      row
        .attr("data-attachment", index)
        .toggleClass("active");

      row.find("[type=text]").val("");
      row.find("[name]").attr("name", function(i, currentName) { return currentName.replace("attachments["+previousIndex+"]", "attachments["+index+"]") });
      row.find("[for]").attr("for", function(i, currentFor) { return currentFor.replace("attachments["+previousIndex+"]", "attachments["+index+"]") });
    });

    firstAttachmentRow.find("[name='attachments["+index+"][id]']").remove();
    firstAttachmentRow.find("[name='attachments["+index+"][display_order]']").val(index);
    firstAttachmentRow.find("[data-remove-attachment]").attr("data-remove-attachment", index);

    enableDisableRemoveAttachmentButtons();
  }

  function enableDisableRemoveAttachmentButtons() {
    var removeButtons = $("[data-remove-attachment]");
    if(removeButtons.length == 1) {
      removeButtons.attr("disabled", "disabled");
    } else {
      removeButtons.removeAttr("disabled");
    }
  }

  function removeAttachment(attachmentIndex) {
    $("[data-attachment="+attachmentIndex+"]").remove();

    $.each([".attachment.child-first-row", ".attachment.child-second-row"], function(i, selector) {
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

    enableDisableRemoveAttachmentButtons();
  }

  function addAttack() {
    var firstAttackRow = $(".attack.child-first-row:last").clone(true);
    var secondAttackRow = $(".attack.child-second-row:last").clone(true);
    var previousIndex = parseInt(firstAttackRow.attr("data-attack"));
    var index = previousIndex + 1;
    var attackTable = $(".attack.child-table");

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
    firstAttackRow.find("select").val(function() { return $(this).find("option:first").val() }).change();
    firstAttackRow.find("[data-remove-attack]").attr("data-remove-attack", index);

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

    $.each([".attack.child-first-row", ".attack.child-second-row"], function(i, selector) {
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

  function setDefenseFromSilhouette() {
    var container = $(".defense-container");
    var silhouette = parseInt($("#silhouette").val());

    if(silhouette > 4) {
      container.addClass("four-zones").removeClass("two-zones");
    } else {
      container.removeClass("four-zones").addClass("two-zones");
    }
  }

  function initializeHandlers() {
    $("#silhouette").change(setDefenseFromSilhouette);
    $("[data-remove-attack]").click(function() { removeAttack($(this).attr("data-remove-attack")) });
    $("#addAttackButton").click(addAttack);
    $("[data-remove-attachment]").click(function() { removeAttachment($(this).attr("data-remove-attachment")) });
    $("#addAttachmentButton").click(addAttachment);
  }

  return {
    init: function() {
      initializeHandlers();
      setDefenseFromSilhouette();
      enableDisableRemoveAttackButtons();
      enableDisableRemoveAttachmentButtons();
    }
  };
})();

$(VehicleForm.init);
