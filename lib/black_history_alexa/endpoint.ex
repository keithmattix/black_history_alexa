defmodule BlackHistoryAlexa.Endpoint do
  use Phoenix.Endpoint, otp_app: :black_history_alexa

  socket "/socket", BlackHistoryAlexa.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :black_history_alexa, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  defp copy_req_body(conn, _) do
    require Logger
    Logger.info "Copying response body"
    {:ok, body, _} = Plug.Conn.read_body(conn)
    Logger.info "Copied response body"
    Plug.Conn.put_private(conn, :raw_body, body)
  end

  plug :copy_req_body

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_black_history_alexa_key",
    signing_salt: "X48LSLOH"

  plug BlackHistoryAlexa.Router
end
