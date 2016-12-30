defmodule BlackHistoryAlexa.AlexaController do
  use BlackHistoryAlexa.Web, :controller
  use PhoenixAlexa.Controller, :retrieve
  @months ["january", "february", "march", "april", "may", "june", "july",
          "august", "september", "october", "november", "december"]

  def launch_request(conn, _request) do
    response =
      %Response{}
      |> set_output_speech(%TextOutputSpeech{text: "Welcome to the BlackHistory Calendar."})

    conn |> set_response(response)
  end

  def session_end_request(conn, _request) do
    conn
  end

  def intent_request(conn, "GetEvent", request) do
    date =
      request.request.intent.slots["Date"]["value"]
      |> Timex.parse("{YYYY}-{0M}-{D}")
      |> Timex.to_datetime
    month = Map.get(date, :month)
    day = Map.get(date, :day)
    data_url = Application.get_env(:black_history_alexa, :config)[:data_url]
    body =
      :body
      |> Map.get(HTTPoison.get!(data_url))
      |> Map.get(month)
    event = Enum.at(body, day)
    response =
      %Response{}
      |> set_output_speech(%TextOutputSpeech{text: event})
      |> set_should_end_session(true)
    conn |> set_response(response)
  end
end
