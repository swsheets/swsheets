var VehicleShow = (function() {
  function setDefenseFromSilhouette() {
    var container = $(".defense-container");
    var silhouette = parseInt($("#silhouette").val());

    if (silhouette > 4) {
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
    $("#incrementDefenseFore").click(function() {
      incrementDefenseFore(1);
    });
    $("#decrementDefenseFore").click(function() {
      incrementDefenseFore(-1);
    });
    $("#incrementDefenseAft").click(function() {
      incrementDefenseAft(1);
    });
    $("#decrementDefenseAft").click(function() {
      incrementDefenseAft(-1);
    });
    $("#incrementDefensePort").click(function() {
      incrementDefensePort(1);
    });
    $("#decrementDefensePort").click(function() {
      incrementDefensePort(-1);
    });
    $("#incrementDefenseStarboard").click(function() {
      incrementDefenseStarboard(1);
    });
    $("#decrementDefenseStarboard").click(function() {
      incrementDefenseStarboard(-1);
    });
    $("#incrementSpeed").click(function() {
      incrementSpeed(1);
    });
    $("#decrementSpeed").click(function() {
      incrementSpeed(-1);
    });
  }

  function incrementHullTrauma(num) {
    incrementValue("hull_current", $("#currentHullTrauma"), num);
  }

  function incrementSystemStrain(num) {
    incrementValue("strain_current", $("#currentSystemStrain"), num);
  }

  function incrementDefenseFore(num) {
    incrementValue("defense_fore_current", $("#currentDefenseFore"), num);
  }

  function incrementDefenseAft(num) {
    incrementValue("defense_aft_current", $("#currentDefenseAft"), num);
  }

  function incrementDefensePort(num) {
    incrementValue("defense_port_current", $("#currentDefensePort"), num);
  }

  function incrementDefenseStarboard(num) {
    incrementValue(
      "defense_starboard_current",
      $("#currentDefenseStarboard"),
      num
    );
  }

  function incrementSpeed(num) {
    incrementValue("current_speed", $("#currentSpeed"), num);
  }

  function incrementValue(key, $el, num) {
    var current = parseInt($el.text(), 10),
      updated = current + num,
      vehicleId = window.location.pathname.match(/^\/v\/(.+)$/)[1],
      data = { vehicle: {} };
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
