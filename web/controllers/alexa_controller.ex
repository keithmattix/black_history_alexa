defmodule BlackHistoryAlexa.AlexaController do
  use BlackHistoryAlexa.Web, :controller
  use PhoenixAlexa.Controller, :retrieve

  def launch_request(conn, request) do
    response =
      %Response{}
      |> set_output_speech(%TextOutputSpeech{text: "Welcome to the BlackHistory Calendar."})

    conn |> set_response(response)
  end

  def session_end_request(conn, request) do
    conn
  end

  def intent_request(conn, "GetEvent", request) do
    date = request.request.intent.slots["Date"]["Value"]
    data_url = Application.get_env(:black_history_alexa, :config)[:data_url]
    response = Map.get(:body, HTTPoison.get!(data_url))
  end
end
