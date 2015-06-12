defmodule EdgeBuilder.VehicleView do
  use EdgeBuilder.Web, :view
  import Ecto.Changeset, only: [get_field: 2]

  def image_or_default(vehicle) do
    get_field(vehicle, :picture_url) || "/images/250x250.gif"
  end
end
