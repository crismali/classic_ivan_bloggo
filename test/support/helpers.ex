defmodule IvanBloggo.Helpers do
  alias IvanBloggo.Repo
  import Ecto.Query, only: [from: 2]

  def count(model_module) do
    query = from(model in model_module, select: count(model.id))
    [count] = Repo.all(query)
    count
  end
end
