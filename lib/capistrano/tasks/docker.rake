namespace :docker do
  desc "Build and start Docker containers"
  task :deploy do
    on roles(:app) do
      within release_path do
        execute :docker, "compose", "-f", "docker-compose.yml", "down"
        execute :docker, "compose", "-f", "docker-compose.yml", "build", "--no-cache"
        execute :docker, "compose", "-f", "docker-compose.yml", "up", "-d"
      end
    end
  end

  desc "Run database migrations"
  task :migrate do
    on roles(:app) do
      within release_path do
        execute :docker, "compose", "-f", "docker-compose.yml", "exec", "-T", "web", "bundle", "exec", "rails", "db:migrate"
      end
    end
  end

  desc "Restart application"
  task :restart do
    on roles(:app) do
      within release_path do
        execute :docker, "compose", "-f", "docker-compose.yml", "restart", "web"
      end
    end
  end
end

# Hook into Capistrano deployment
after "deploy:published", "docker:deploy"
after "docker:deploy", "docker:migrate"