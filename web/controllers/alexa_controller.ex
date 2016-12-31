defmodule BlackHistoryAlexa.AlexaController do
  use BlackHistoryAlexa.Web, :controller
  use PhoenixAlexa.Controller, :retrieve
  use Export.Ruby
  require Logger

  @months ["january", "february", "march", "april", "may", "june", "july",
          "august", "september", "october", "november", "december"]

  plug :verify_request

  def launch_request(conn, _request) do
    response =
      %Response{}
      |> set_output_speech(%TextOutputSpeech{text: "Welcome to the BlackHistory Calendar."})

    conn |> set_response(response)
  end

  def session_end_request(conn, _request) do
    conn
  end

  def verify_request(conn, _request) do
    {:ok, raw_request_body} = conn.body_params |> Poison.encode
    cert_chain_url = conn |> get_req_header("signaturecertchainurl")
    signature = conn |> get_req_header("signature") |> List.first
    Logger.debug "Signature: #{inspect(signature)}"
    {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(cert_chain_url)
    {:ok, ruby} = Ruby.start(ruby_lib: Path.expand("lib/black_history_alexa/ruby"))
    Logger.info "Asserted Hash"
    asserted_hash = ruby |> Ruby.call("ssl_decode", "decode", [body, signature])
    Logger.debug "#{inspect(asserted_hash)}"
    Logger.info "Raw request body:"
    Logger.debug "#{inspect(raw_request_body)}"
    derived_hash = :crypto.hash(:sha, raw_request_body)
    Logger.info "Derived hash:"
    Logger.debug "#{inspect(derived_hash)}"
    conn
  end

  def intent_request(conn, "GetEvent", request) do
    case request.request.intent.slots["Date"]["value"] |> Timex.parse("{YYYY}-{0M}-{D}") do
      {:error, _} ->
        error_message = "I'm sorry, that was not a valid request. If you need help, just say help."
        response =
          %Response{}
          |> set_output_speech(%TextOutputSpeech{text: error_message})

        conn |> set_response(response)
      {:ok, d} ->
        date = Timex.to_datetime(d)
        month = Map.get(date, :month) |> Timex.month_name |> String.downcase
        day = Map.get(date, :day)
        data_url = Application.get_env(:black_history_alexa, :config)[:data_url]
        body =
          data_url
          |> HTTPoison.get!
          |> Map.get(:body)
          |> Poison.decode!
          |> Map.get(month)
        event = Enum.at(body, day)
        response =
          %Response{}
          |> set_output_speech(%TextOutputSpeech{text: event})
          |> set_should_end_session(true)
        conn |> set_response(response)
    end
  end

  def intent_request(conn, "AMAZON.HelpIntent", _request) do
    help_ssml = """
    <speak>
    To find out about events in black history, just ask: What happened today?
    <break strength="strong" /> or What happened tomorrow?
    For any other day, for example <say-as interpret-as="date" format="md">January 2nd</say-as>,
    ask me: What happened on <say-as interpret-as="date" format="md">January 2nd</say-as>?
    </speak>
    """
    response =
      %Response{}
      |> set_output_speech(%SsmlOutputSpeech{ssml: help_ssml})

    conn |> set_response(response)
  end

  def intent_request(conn, intent, _request) when intent in ["AMAZON.StopIntent", "AMAZON.CancelIntent"] do
    response =
      %Response{}
      |> set_output_speech(%TextOutputSpeech{text: "Goodbye."})
      |> set_should_end_session(true)

    conn |> set_response(response)
  end

  def intent_request(conn, _intent, _request) do
    error_message = "I'm sorry, that was not a valid request. If you need help, just say help."
    response =
      %Response{}
      |> set_output_speech(%TextOutputSpeech{text: error_message})

    conn |> set_response(response)
  end
end
