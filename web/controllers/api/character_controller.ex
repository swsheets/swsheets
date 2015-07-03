defmodule EdgeBuilder.API.CharacterController do
  use EdgeBuilder.Web, :controller

  def update(conn, params) do
    put_status(conn, 200)
    |> json  %{strain_current: params["strain_current"]}
  end
end
