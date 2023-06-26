defmodule Proj.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Proj.Repo,
      # Starts a worker by calling: Proj.Worker.start_link(arg)
      # {Proj.Worker, arg}
    ]

    # Proj.main()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proj.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
