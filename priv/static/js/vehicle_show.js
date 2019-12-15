var VehicleShow = (function() {
  function setDefenseFromSilhouette() {
    var container = $(".defense-container");
    var silhouette = parseInt($("#silhouette").val());

    if(silhouette > 4) {
      container.addClass("four-zones").removeClass("two-zones");
    } else {
      container.removeClass("four-zones").addClass("two-zones");
    }
  }

  function initializeIncrementers() {
    $("#incrementHullTrauma").click(function() {
      incrementHullTrauma(1);
    });
    $("#decrementHullTrauma").click(function() {
      incrementHullTrauma(-1);
    });
    $("#incrementSystemStrain").click(function() {
      incrementSystemStrain(1);
    });
    $("#decrementSystemStrain").click(function() {
      incrementSystemStrain(-1);
    });
  }

  function incrementHullTrauma(num) {
    incrementValue("hull_current", $("#currentHullTrauma"), num);
  }

  function incrementSystemStrain(num) {
    incrementValue("strain_current", $("#currentSystemStrain"), num);
  }

  function incrementValue(key, $el, num) {
    var current = parseInt($el.text(), 10),
        updated = current + num,
        vehicleId = window.location.pathname.match(/^\/v\/(.+)$/)[1],
        data = {vehicle: {}};
    data.vehicle[key] = updated;
    $el.text("" + updated);
    $.ajax({
      method: "PUT",
      url: "/api/vehicles/" + vehicleId,
      data: JSON.stringify(data),
      dataType: "json",
      contentType: "application/json"
    });
  }

  return {
    init: function() {
      setDefenseFromSilhouette();
      initializeIncrementers();
    }
  };
})();

$(VehicleShow.init);
