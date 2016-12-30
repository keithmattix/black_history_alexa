defmodule BlackHistoryAlexa.Router do
  use BlackHistoryAlexa.Web, :router
  alias PhoenixAlexa.ValidateApplicationId

  pipeline :api do
    plug :accepts, ["json"]
    plug ValidateApplicationId, ""
  end

  scope "/api", BlackHistoryAlexa do
    pipe_through :api

    post "/", AlexaController, :retrieve
  end

end
