server "207.180.210.123", user: "root", roles: %w{app db web}

set :rails_env, "production"
set :branch, "main"

# SSH options
set :ssh_options, {
  keys: %w(/home/user/.ssh/id_rsa),
  forward_agent: false,
  auth_methods: %w(password)
}

# Deploy path
set :deploy_to, "/opt/fiscodata/api-fiscodata-assinatura"

# Linked files
append :linked_files, "config/master.key", ".env.production"

# Linked directories
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"