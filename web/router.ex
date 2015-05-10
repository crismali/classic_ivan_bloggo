defmodule IvanBloggo.Router do
  use IvanBloggo.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", IvanBloggo do
    pipe_through :browser # Use the default browser stack

    post "/sign_in", SessionController, :create, as: :session
    get "/sign_in", SessionController, :new, as: :session
    delete "/sign_in", SessionController, :delete, as: :session

    resources "/sign_up", RegistrationController, only: [:create, :new], as: :registration
    resources "/posts", PostController

    get "/", PostController, :index, as: :root
  end

  # Other scopes may use custom stacks.
  # scope "/api", IvanBloggo do
  #   pipe_through :api
  # end
end
