defmodule EdgeBuilder.ViewHelpers do
  def application_name, do: Application.get_env(:edge_builder, :application_name)

  def format_date(nil), do: nil
  def format_date(date) do
    date |> Ecto.DateTime.to_date |> Ecto.Date.to_string
  end
end
