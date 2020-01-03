defmodule Twitterclone.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      supervisor(Twitterclone.Repo, []),
      supervisor(TwittercloneWeb.Endpoint, []),
      worker(Twitter.Server, [])
    ]
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    TwittercloneWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # def start(_type,_args) do
    
  #   Server.startServer()
  #   Process.sleep(2000)
  #   IO.puts("hello")
  #   pid = self()
  #   :global.register_name(:pilotProc,pid)
  #   # Task.start(fn() -> Client.startClient(pid) end)
  #   receive do
  #     {:receivePpid,ppid} -> :ok
  #   end
  #   IO.inspect "Process completed"
  # end


end
