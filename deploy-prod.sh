#!/bin/bash
set -e

echo "🚀 Iniciando deploy em produção..."

# Carregar variáveis de ambiente
export $(cat .env.production | xargs)

# Parar containers
docker-compose -f docker-compose.yml down

# Pull código atualizado
git pull origin main

# Build imagens de produção
docker-compose -f docker-compose.yml build --no-cache

# Iniciar containers
docker-compose -f docker-compose.yml up -d

# Aguardar serviços ficarem saudáveis
echo "⏳ Aguardando serviços..."
sleep 30

# Executar migrations
docker-compose -f docker-compose.yml exec web rails db:migrate

# Verificar status
docker-compose -f docker-compose.yml ps

echo "✅ Deploy concluído!"
