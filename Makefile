.PHONY: build up down logs shell db-setup clean

# Build da aplicação
build:
	docker-compose -f docker-compose.local.yml build

# Subir os serviços
up:
	docker-compose -f docker-compose.local.yml up -d

# Subir os serviços em modo desenvolvimento (com logs)
dev:
	docker-compose -f docker-compose.local.yml up

# Parar os serviços
down:
	docker-compose -f docker-compose.local.yml down

# Ver logs
logs:
	docker-compose -f docker-compose.local.yml logs -f

# Acessar shell da aplicação
shell:
	docker-compose -f docker-compose.local.yml exec web bash

# Configurar banco de dados
db-setup:
	docker-compose -f docker-compose.local.yml exec web bundle exec rails db:create db:migrate db:seed

# Limpar containers e volumes
clean:
	docker-compose -f docker-compose.local.yml down -v
	docker system prune -f

# Executar testes
test:
	docker-compose -f docker-compose.local.yml exec web bundle exec rails test

# Executar console Rails
console:
	docker-compose -f docker-compose.local.yml exec web bundle exec rails console

# Instalar dependências
install:
	docker-compose -f docker-compose.local.yml run --rm web bundle install
	docker-compose -f docker-compose.local.yml run --rm web yarn install