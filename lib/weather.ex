defmodule Weather do
  @moduledoc """
  Documentation for Weather.
  """

  @doc """
  """
  def main(argv) do
    fetch_weather()
    |> IO.inspect
  end

  defp fetch_weather do
    HTTPoison.get("https://w1.weather.gov/xml/current_obs/KDTO.xml", [
      {"User-agent", "Elixir a@b.com"}
    ])
    |> extract_xml
  end

  defp extract_xml({:ok, %{body: body, status_code: 200}}) do
    body
    |> String.to_charlist
    |> :xmerl_scan.string
  end
  defp extract_xml({:ok, %{status_code: code}}) do
    to_string code
  end
  defp extract_xml({:error, _}) do
    "error"
  end
end
