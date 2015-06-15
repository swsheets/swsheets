var VehicleForm = (function() {
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
  }

  return {
    init: function() {
      initializeHandlers();
      setDefenseFromSilhouette();
    }
  };
})();

$(VehicleForm.init);
