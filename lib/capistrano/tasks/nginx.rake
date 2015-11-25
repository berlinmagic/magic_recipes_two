require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers


namespace :load do
  task :defaults do
    set :nginx_domains,               -> { [] }
    set :nginx_major_domain,          -> { false }
    set :nginx_remove_www,            -> { true }
    set :default_site,                -> { false }
    set :app_instances,               -> { 1 }
    set :nginx_service_path,          -> { 'service nginx' }
    set :nginx_roles,                 -> { :web }
    set :nginx_log_path,              -> { "#{shared_path}/log" }
    set :nginx_root_path,             -> { "/etc/nginx" }
    set :nginx_static_dir,            -> { "public" }
    set :nginx_sites_enabled,         -> { "sites-enabled" }
    set :nginx_sites_available,       -> { "sites-available" }
    set :nginx_template,              -> { :default }
    set :nginx_use_ssl,               -> { false }
    set :nginx_ssl_certificate,       -> { "#{fetch(:application)}.crt" }
    set :nginx_ssl_certificate_path,  -> { '/etc/ssl/certs' }
    set :nginx_ssl_certificate_key,   -> { "#{fetch(:application)}.crt" }
    set :nginx_ssl_certificate_key_path, -> { '/etc/ssl/private' }
    set :app_server_ip,               -> { "127.0.0.1" }
    ## NginX Proxy-Caching
    # Cache Rails
    set :proxy_cache_rails,           -> { false }
    set :proxy_cache_rails_directory, -> { "#{shared_path}/tmp/proxy_cache/rails" }
    set :proxy_cache_rails_levels,    -> { "1:2" }
    set :proxy_cache_rails_name,      -> { "RAILS_#{fetch(:application)}_#{fetch(:stage)}_CACHE" }
    set :proxy_cache_rails_size,      -> { "4m" }
    set :proxy_cache_rails_time,      -> { "24h" }
    set :proxy_cache_rails_max,       -> { "1g" }
    set :proxy_cache_rails_200,       -> { false }
    set :proxy_cache_rails_404,       -> { "60m" }
    set :proxy_cache_rails_stale,     -> { ["error", "timeout", "invalid_header", "updating"] }
    # Cache Media (Dragonfly)
    set :proxy_cache_media,           -> { false }
    set :proxy_cache_media_path,      -> { "media" }
    set :proxy_cache_media_directory, -> { "#{shared_path}/tmp/proxy_cache/media" }
    set :proxy_cache_media_levels,    -> { "1:2" }
    set :proxy_cache_media_name,      -> { "MEDIA_#{fetch(:application)}_#{fetch(:stage)}_CACHE" }
    set :proxy_cache_media_size,      -> { "2m" }
    set :proxy_cache_media_time,      -> { "48h" }
    set :proxy_cache_media_max,       -> { "1g" }
  end
end

namespace :nginx do
  task :load_vars do
    set :sites_available, -> { File.join(fetch(:nginx_root_path), fetch(:nginx_sites_available)) }
    set :sites_enabled, -> { File.join(fetch(:nginx_root_path), fetch(:nginx_sites_enabled)) }
    set :enabled_application, -> { File.join(fetch(:sites_enabled), "#{fetch(:application)}_#{fetch(:stage)}") }
    set :available_application, -> { File.join(fetch(:sites_available), "#{fetch(:application)}_#{fetch(:stage)}") }
  end

  %w[start stop restart reload].each do |command|
    desc "#{command.capitalize} nginx service"
    task command do
      nginx_service = fetch(:nginx_service_path)
      on release_roles fetch(:nginx_roles) do
        if command === 'stop' || (test "[ $(sudo #{nginx_service} configtest | grep -c 'fail') -eq 0 ]")
          execute :sudo, "#{nginx_service} #{command}"
        end
      end
    end
  end

  after 'deploy:check', nil do
    on release_roles fetch(:nginx_roles) do
      execute :mkdir, '-pv', fetch(:nginx_log_path)
      execute :mkdir, '-pv', fetch(:proxy_cache_rails_directory)   if fetch(:proxy_cache_rails)
      execute :mkdir, '-pv', fetch(:proxy_cache_media_directory)   if fetch(:proxy_cache_media)
    end
  end

  namespace :site do
    desc 'Creates the site configuration and upload it to the available folder'
    task :add => ['nginx:load_vars'] do
      on release_roles fetch(:nginx_roles) do
        within fetch(:sites_available) do
          config_file = fetch(:nginx_template)
          if config_file == :default
            # config_file = File.expand_path("../../../../config/deploy/templates/nginx.conf.erb", __FILE__)
            magic_template("nginx.conf", '/tmp/nginx.conf')
          else
            template(config_file, '/tmp/nginx.conf')
          end
          # config = ERB.new(File.read(config_file)).result(binding)
          # upload! StringIO.new(config), '/tmp/nginx.conf'
          

          execute :sudo, :mv, '/tmp/nginx.conf', "#{fetch(:application)}_#{fetch(:stage)}"
        end
      end
    end

    desc 'Enables the site creating a symbolic link into the enabled folder'
    task :enable => ['nginx:load_vars'] do
      on release_roles fetch(:nginx_roles) do
        if test "! [ -h #{fetch(:enabled_application)} ]"
          within fetch(:sites_enabled) do
            execute :sudo, :ln, '-nfs', fetch(:available_application), fetch(:enabled_application)
          end
        end
      end
    end

    desc 'Disables the site removing the symbolic link located in the enabled folder'
    task :disable => ['nginx:load_vars'] do
      on release_roles fetch(:nginx_roles) do
        if test "[ -f #{fetch(:enabled_application)} ]"
          within fetch(:sites_enabled) do
            execute :sudo, :rm, '-f', "#{fetch(:application)}_#{fetch(:stage)}"
          end
        end
      end
    end

    desc 'Removes the site removing the configuration file from the available folder'
    task :remove => ['nginx:load_vars'] do
      on release_roles fetch(:nginx_roles) do
        if test "[ -f #{fetch(:available_application)} ]"
          within fetch(:sites_available) do
            execute :sudo, :rm, "#{fetch(:application)}_#{fetch(:stage)}"
          end
        end
      end
    end
  end
end