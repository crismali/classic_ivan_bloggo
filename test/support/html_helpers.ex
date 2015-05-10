defmodule IvanBloggo.HtmlHelpers do
  import Floki, only: [attribute: 2, find: 2, text: 1]

  def text_for(html, selector) do
    find(html, selector) |> text
  end

  def attribute_for(html, selector, attribute_name) do
    find(html, selector) |> attribute(attribute_name)
  end
end
