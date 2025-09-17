namespace :deploy do
  desc "Deploy with Docker"
  task :docker do
    on roles(:app) do
      within release_path do
        # Stop containers
        execute :docker, "compose", "-f", "docker-compose.yml", "down"
        
        # Build and start
        execute :docker, "compose", "-f", "docker-compose.yml", "build", "--no-cache"
        execute :docker, "compose", "-f", "docker-compose.yml", "up", "-d"
        
        # Wait for services
        execute :sleep, "30"
        
        # Run migrations
        execute :docker, "compose", "-f", "docker-compose.yml", "exec", "-T", "web", "bundle", "exec", "rails", "db:migrate"
      end
    end
  end

  desc "Update existing project with Docker"
  task :update_full do
    on roles(:app) do
      # Carregar variáveis de ambiente em um único comando
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && git pull origin main"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml down"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml build --no-cache"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml up -d"
      execute "sleep 30"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml exec -T web bundle exec rails db:migrate"
    end
  end

  desc "Update existing project with Docker"
  task :update_quick do
    on roles(:app) do
      # Carregar variáveis de ambiente em um único comando
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml down"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && git pull origin main"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml build"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml up -d"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml exec -T web bundle exec rails db:migrate"
      execute "cd /opt/fiscodata/api-fiscodata-assinatura && export $(grep -v '^#' .env.production | grep -v '^$' | xargs) && docker-compose -f docker-compose.yml restart web worker"
    end
  end
end