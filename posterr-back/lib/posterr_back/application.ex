defmodule PosterrBack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PosterrBackWeb.Telemetry,
      PosterrBack.Repo,
      {DNSCluster, query: Application.get_env(:posterr_back, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PosterrBack.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PosterrBack.Finch},
      # Start a worker by calling: PosterrBack.Worker.start_link(arg)
      # {PosterrBack.Worker, arg},
      # Start to serve requests, typically the last entry
      PosterrBackWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PosterrBack.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PosterrBackWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
