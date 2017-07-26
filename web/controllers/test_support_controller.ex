# The entire purpose of this controller is awful. It exists only as a way to
# set connection state quickly during test. The proper login route is
# (correctly) too slow to be used for this purpose.
defmodule EdgeBuilder.TestSupportController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.User
  alias EdgeBuilder.Repo

  def fake_login(conn, %{"id" => id}) do
    if Mix.env == :test do
      set_current_user(conn, Repo.get(User, id))
      |> redirect(to: "/")
    else
      render_404(conn)
    end
  end
end
