# Imagem base Ruby
FROM ruby:3.1.2

# SO deps (sem nodejs/npm do Debian!)
RUN apt-get update -qq && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    build-essential \
    libpq-dev \
    libffi-dev \           
    imagemagick \
    libmagickwand-dev \
    wkhtmltopdf \
    xvfb \
  && rm -rf /var/lib/apt/lists/*

# Node 18 LTS via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Usuário não-root
RUN groupadd -r app && useradd -r -g app app
WORKDIR /app

# ===== Bundler (cache-friendly) =====
COPY Gemfile Gemfile.lock ./

ENV RAILS_ENV=production
ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_WITHOUT="development:test"

# Alinhar bundler à versão do lockfile e forçar build nativo (ffi)
RUN gem install bundler:2.3.16
RUN bundle config set force_ruby_platform true
RUN bundle install --jobs 4 --retry 3

# ===== Node (npm) =====
# Use npm com lockfile oficial (package-lock.json).
# IMPORTANTE: não use npm --production aqui, pois você precisa das devDeps para compilar os assets.
COPY package.json package-lock.json ./
RUN npm ci

# ===== Código da aplicação =====
COPY . .

# Precompile assets (defina SECRET_KEY_BASE se o seu app exigir no build)
# ENV SECRET_KEY_BASE=dummy-for-build
RUN node -v && npm -v  # sanity check (remova depois se quiser)

# Diretórios e permissões
RUN mkdir -p log tmp/pids tmp/cache tmp/sockets storage && \
    chown -R app:app /app && \
    chmod -R 0755 /app

# Entrypoint
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

USER app
EXPOSE 3000
ENTRYPOINT ["entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
