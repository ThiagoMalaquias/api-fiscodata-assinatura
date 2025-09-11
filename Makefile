.PHONY: build up down logs shell db-setup clean

# Build da aplicação
build:
	docker-compose build

# Subir os serviços
up:
	docker-compose up -d

# Subir os serviços em modo desenvolvimento (com logs)
dev:
	docker-compose up

# Parar os serviços
down:
	docker-compose down

# Ver logs
logs:
	docker-compose logs -f

# Acessar shell da aplicação
shell:
	docker-compose exec web bash

# Configurar banco de dados
db-setup:
	docker-compose exec web bundle exec rails db:create db:migrate db:seed

# Limpar containers e volumes
clean:
	docker-compose down -v
	docker system prune -f

# Executar testes
test:
	docker-compose exec web bundle exec rails test

# Executar console Rails
console:
	docker-compose exec web bundle exec rails console

# Instalar dependências
install:
	docker-compose run --rm web bundle install
	docker-compose run --rm web yarn install