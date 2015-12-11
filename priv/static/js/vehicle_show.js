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

  function initializeAddToFavoriteList() {
    $("#addToFavoriteListSelect").selectize({
      create: true
    });
  }

  function init() {
    setDefenseFromSilhouette();
    initializeAddToFavoriteList();
  }

  return {
    init: init
  };
})();

$(VehicleShow.init);
