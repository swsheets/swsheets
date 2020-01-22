defmodule EdgeBuilder.PageController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User

  def index(conn, _params) do
    characters = EdgeBuilder.Repositories.CharacterRepo.recent()
    vehicles = EdgeBuilder.Repositories.VehicleRepo.recent()

    render conn, :index,
      contributors: User.contributors(5),
      characters: characters,
      vehicles: vehicles,
      has_reset_password: get_flash(conn, :has_reset_password)
  end

  def thanks(conn, _params) do
    render conn, :thanks,
      pull_requesters: User.pull_requesters,
      bug_reporters: User.bug_reporters
  end

  def about(conn, _params) do
    render conn, :about
  end
end
