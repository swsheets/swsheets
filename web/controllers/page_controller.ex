defmodule EdgeBuilder.PageController do
  use EdgeBuilder.Web, :controller

  alias EdgeBuilder.Models.Character
  alias EdgeBuilder.Repo
  import Ecto.Query, only: [from: 2]

  plug :action

  def index(conn, params) do
    page = Repo.paginate((from c in Character, order_by: [desc: :inserted_at], limit: 30), page: params["page"], page_size: 5)

    render conn, :index,
      characters: page.entries,
      page_number: page.page_number,
      total_pages: page.total_pages
  end
end
