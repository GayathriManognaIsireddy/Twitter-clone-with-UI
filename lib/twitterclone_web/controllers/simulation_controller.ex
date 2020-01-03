defmodule TwittercloneWeb.SimulationController do
  use TwittercloneWeb, :controller


  def index(conn, _params) do
    render(conn, "index.html")
  end
end
