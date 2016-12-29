defmodule WebClient.PageController do
  use WebClient.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
