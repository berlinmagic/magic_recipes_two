
namespace :load do
  task :defaults do
    set :redis_roles, -> { :web }
    set :redis_pid, -> { "/var/run/redis/redis-server.pid" }
  end
end

namespace :redis do
  desc "Install the latest release of Redis"
  task :install do
    
    on release_roles fetch(:redis_roles) do
      execute :sudo, "apt-get -y update"
      execute :sudo, "apt-get -y upgrade"
      execute :sudo, "apt-get -y install redis-server"
      # save default config, for security
      execute :sudo, :cp, "/etc/redis/redis.conf /etc/redis/redis.conf.default"
    end
    
  end
  # => after "deploy:install", "redis:install"

  %w[start stop restart].each do |command|
    desc "#{command} REDIS server"
    task command do
      on release_roles fetch(:redis_roles) do
        execute :sudo, :service, "redis-server #{command}"
      end
    end
  end
end