defmodule EdgeBuilder.VehicleView do
  use EdgeBuilder.Web, :view

  def image_or_default(vehicle) do
    get_field(vehicle, :portrait_url) || "/images/250x250.gif"
  end
end
