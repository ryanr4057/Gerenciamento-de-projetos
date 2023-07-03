import Config

config :proj,
  ecto_repos: [Proj.Repo]

config :proj, Proj.Repo,
  database: "database.sqlite3",
  username: "",
  password: "",
  hostname: ""

# config :logger, level: :warning
