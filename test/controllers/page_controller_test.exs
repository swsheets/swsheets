defmodule EdgeBuilder.Controllers.PageControllerTest do
  use ExSpec
  use Plug.Test

  @opts []

  describe "reference" do
    it "renders the reference HTML" do
      conn = conn(:get, "/reference") |> EdgeBuilder.Endpoint.call(@opts)

      assert String.contains?(conn.resp_body, "Character Name")
    end
  end
end
