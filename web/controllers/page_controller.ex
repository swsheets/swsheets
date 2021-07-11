defmodule EdgeBuilder.PageController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User

  def index(conn, _params) do
    characters = EdgeBuilder.Repositories.CharacterRepo.recent()
    vehicles = EdgeBuilder.Repositories.VehicleRepo.recent()

    render(conn, :index,
      contributors: User.contributors(5),
      characters: characters,
      vehicles: vehicles,
      has_reset_password: get_flash(conn, :has_reset_password)
    )
  end

  def thanks(conn, _params) do
    render(conn, :thanks,
      pull_requesters: User.pull_requesters(),
      bug_reporters: User.bug_reporters()
    )
  end

  def about(conn, _params) do
    render(conn, :about)
  end

  def supporters(conn, _params) do
    render(conn, :supporters,
      donators: ["Andrew J.", "David B.", "Marshall M.", "Soren H.", "Eric S."],
      padawans: ["Bryan", "Austin W.", "Geoff R.", "Ben B.", "Leslie", "Erik J.", "Chad O."],
      jedis: [],
      senates: ["Brad K.", "Simon B."]
    )
  end

  # Differing from the `thanks` route in that this one is the one a user gets
  # redirected back to if they donate via PayPal.
  def thank_you(conn, _params) do
    render(conn, :thank_you)
  end
end
