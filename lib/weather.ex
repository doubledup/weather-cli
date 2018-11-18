defmodule Weather do
  require Record
  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  @moduledoc """
  Documentation for Weather.
  """

  @doc """
  """
  def main(_argv) do
    weather = fetch_weather()

    IO.puts(format_map(weather))
  end

  defp fetch_weather do
    HTTPoison.get("https://w1.weather.gov/xml/current_obs/KDTO.xml", [
      {"User-agent", "Elixir a@b.com"}
    ])
    |> extract_xml
  end

  defp extract_xml({:ok, %{body: body, status_code: 200}}) do
    {doc, _rest} =
      body
      |> String.to_charlist()
      |> :xmerl_scan.string()

    :xmerl_xpath.string('//current_observation', doc)
    |> Enum.map(fn event ->
      parse(xmlElement(event, :content))
    end)
    |> List.first()
  end

  defp extract_xml({:ok, %{status_code: code}}) do
    to_string(code)
  end

  defp extract_xml({:error, _}) do
    "error"
  end

  defp parse(node) do
    cond do
      Record.is_record(node, :xmlElement) ->
        name = xmlElement(node, :name)
        content = xmlElement(node, :content)
        Map.put(%{}, name, parse(content))

      Record.is_record(node, :xmlText) ->
        xmlText(node, :value) |> to_string

      is_list(node) ->
        case Enum.map(node, &parse(&1)) do
          [text_content] when is_binary(text_content) ->
            text_content

          elements ->
            Enum.reduce(elements, %{}, fn x, acc ->
              if is_map(x) do
                Map.merge(acc, x)
              else
                acc
              end
            end)
        end

      true ->
        "Not supported to parse #{inspect(node)}"
    end
  end

  defp format_map(weather_info) do
    with title = "Weather info at #{weather_info[:location]}",
         line = String.duplicate("_", String.length(title)),
         temp = "Temperature: #{weather_info[:temp_c]} degrees celsius",
         wind = "Wind is blowing #{weather_info[:wind_string]}",
         pressure = "Pressure: #{weather_info[:pressure_string]}",
         time = weather_info[:observation_time] do
      """
      #{title}
      #{line}
      #{temp}
      #{wind}
      #{pressure}
      #{line}
      #{time}
      """
    end
  end
end
