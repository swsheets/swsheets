defmodule EdgeBuilder.Imgur do
  @moduledoc """
    This module interfaces with Imgur to solve regular
    data entry issues, like the user providing an
    Imgur page URL instead of the image URL.
  """

  def get_image_url_from_page_url(url) when is_bitstring(url) do
    regex = ~r/^https?:\/\/imgur\.com/
    if Regex.match?(regex, url) do
      fetch_image_src_from_imgur(url) || url
    else
      url
    end
  end
  def get_image_url_from_page_url(non_string_value), do: non_string_value

  defp fetch_image_src_from_imgur(url) do
    http_options = [follow_redirect: true, max_redirect: 3, timeout: 3000, recv_timeout: 3000]
    case HTTPoison.get(url, [], http_options) do
      {:ok, %HTTPoison.Response{body: body}} ->
        case Regex.run(~r/rel="image_src"\s+href="([^"]+)"/, body) do
          [_full, correct_url] -> correct_url
          nil -> nil
        end
      {:error, _err} -> nil
    end
  end
end
