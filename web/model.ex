defmodule EdgeBuilder.Model do
  defmacro __using__(_opts) do
    quote do
      use Ecto.Model
      alias EdgeBuilder.Repo
      import Ecto.Query, only: [from: 2]
    end
  end
end
