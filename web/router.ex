defmodule BlackHistoryAlexa.Router do
  use BlackHistoryAlexa.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", BlackHistoryAlexa do
    pipe_through :api

    post "/", AlexaController, :post
  end
end
