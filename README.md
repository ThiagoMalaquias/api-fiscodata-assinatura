# Assinatura API

Descrição curta do projeto.

## Configuração do Ambiente

- Ruby version: 3.1.2
- Rails version: 6.1.4
- Banco de Dados: PostgreSQL

## Instalação Local (Development)

```bash
# Clone o repositório:
git clone <URL_DO_REPOSITÓRIO>

# Build e subir containers:
make build
make up

# Configurar banco de dados:
make db-setup

# Acessar console Rails:
make console

# Acessar shell do container:
make shell
```

## Ambiente de Produção (Contabo)

### Acessar o servidor:

```bash
ssh root@<IP_DO_CONTABO>
cd /opt/fiscodata/api-fiscodata-assinatura
```

### Comandos úteis:

```bash
# Acessar bash do container:
docker-compose -f docker-compose.yml exec web bash

# Acessar Rails Console:
docker-compose -f docker-compose.yml exec web bundle exec rails console

# Ver logs:
docker-compose -f docker-compose.yml logs -f web

# Reiniciar serviços:
docker-compose -f docker-compose.yml restart web

# Status dos containers:
docker-compose -f docker-compose.yml ps

# Ver logs de production
docker-compose -f docker-compose.yml exec web bash
tail -f log/production.log
```

### Deploy:

```bash
./deploy.sh
```

## Funcionalidades

- Sistema de assinatura de documentos
- Gestão de templates
- Gestão de usuários e revisores

## Estrutura de Arquivos
