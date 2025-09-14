# Imagem base Ruby (versão específica para produção)
FROM ruby:3.1.2

# Dependências de SO (otimizadas para produção)
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    imagemagick \
    libmagickwand-dev \
    wkhtmltopdf \
    xvfb \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Instalar Yarn (necessário para Rails assets)
RUN npm install -g yarn

# Criar usuário não-root para segurança
RUN groupadd -r app && useradd -r -g app app

# Diretório de trabalho
WORKDIR /app

# ===== Bundler (cache friendly) =====
COPY Gemfile Gemfile.lock ./

# Configurar para produção
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT=development:test
ENV BUNDLE_PATH=/usr/local/bundle

# Instalar gems de produção apenas
RUN bundle install --frozen --without development test

# ===== Node (npm/yarn) =====
COPY package*.json ./

# Instalar dependências JS com Yarn
RUN yarn install --frozen-lockfile --production

# ===== Código da aplicação =====
COPY . .

# Precompile assets (com RAILS_MASTER_KEY)
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY
RUN bundle exec rails assets:precompile

# Criar diretórios necessários
RUN mkdir -p log tmp/pids tmp/cache tmp/sockets storage && \
    chown -R app:app /app && \
    chmod -R 0755 /app

# Trocar para usuário não-root
USER app

# Porta padrão do Rails
EXPOSE 3000

# Entrypoint otimizado
COPY entrypoint.sh /usr/bin/
USER root
RUN chmod +x /usr/bin/entrypoint.sh
USER app
ENTRYPOINT ["entrypoint.sh"]

# Comando padrão
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]