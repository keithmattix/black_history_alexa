defmodule BlackHistoryAlexa.Router do
  use BlackHistoryAlexa.Web, :router
  alias PhoenixAlexa.ValidateApplicationId

  pipeline :api do
    plug :accepts, ["json"]
    # plug ValidateApplicationId, "amzn1.ask.skill.c2c4f20f-f098-4699-ac56-cebccbabf66b"
  end

  scope "/api", BlackHistoryAlexa do
    pipe_through :api

    post "/", AlexaController, :retrieve
  end

end
