defmodule EdgeBuilder.ViewHelpers do
  def application_name, do: Application.get_env(:edge_builder, :application_name)
end
