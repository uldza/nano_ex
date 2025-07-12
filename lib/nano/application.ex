defmodule Nano.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @app :nano
  use Application

  import Cachex.Spec

  @impl true
  def start(_type, _args) do
    :ok = setup()

    children =
      [
        NanoWeb.Telemetry,
        Nano.Repo,
        {Ecto.Migrator,
         repos: Application.fetch_env!(:nano, :ecto_repos), skip: skip_migrations?()},
        {DNSCluster, query: Application.get_env(:nano, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Nano.PubSub},
        # Start the Finch HTTP client for sending emails
        {Finch, name: Nano.Finch},
        # Start to serve requests, typically the last entry
        NanoWeb.Endpoint,
        KoodWeb.Endpoint
      ] ++ additional_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Nano.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    NanoWeb.Endpoint.config_change(changed, removed)
    KoodWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp setup() do
    # Run all migrations before starting application
    Nano.Release.migrate()
    :ok
  end

  defp additional_children() do
    # Read env variables
    page_domain = Application.get_env(@app, :domain, "kood.pro")

    case Application.get_env(@app, :content_dir) do
      nil ->
        []

      content_dir ->
        [
          {Cachex,
           [
             :content_cache,
             [
               warmers: [
                 warmer(
                   module: Booster.Content,
                   state: {page_domain, content_dir},
                   required: true
                 )
               ]
             ]
           ]}
        ]
    end
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end
end
