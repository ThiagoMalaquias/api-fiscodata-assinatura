lock "~> 3.19.0"

set :application, "api-fiscodata-assinatura"
set :repo_url, "https://github.com/ZaiasNP/contratoFisco-Backend.git"

set :branch, :main

set :deploy_to, "/opt/fiscodata/api-fiscodata-assinatura"

set :format, :airbrussh

set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

set :pty, true

append :linked_files, "config/master.key", ".env.production"

append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"

set :default_env, { path: "/usr/local/bin:$PATH" }

set :local_user, -> { `git config user.name`.chomp }

set :keep_releases, 5

set :ssh_options, {
  forward_agent: false,
  auth_methods: %w(password)
}