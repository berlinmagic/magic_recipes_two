require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    set :pwa_roles,           -> { :web }
    set :pwa_application,     -> { "#{fetch(:application)}_mobile" }
    
    set :pwa_root_path,       -> { "#{ current_path }/dist" }
    set :pwa_local_path,      -> { "./dist/" }
    
    set :pwa_domains,         -> { [] }
    set :pwa_major_domain,    -> { false }
    set :pwa_ssl_domains,     -> { fetch(:pwa_major_domain,false) ? [fetch(:pwa_major_domain)] + Array(fetch(:pwa_domains)) : Array(fetch(:pwa_domains)) }
    set :pwa_is_default_site, -> { false }
    set :pwa_nginx_hooks,     -> { false }
    
    set :pwa_use_ssl,         -> { false }
    set :pwa_ssl_cert,        -> { "" }
    set :pwa_ssl_key,         -> { "" }
  end
end

namespace :lets_encrypt do
  
  desc "Generate PWA LetsEncrypt certificate"
  task :pwa_certonly do
    on release_roles fetch(:lets_encrypt_roles) do
      execute :sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto --non-interactive --agree-tos --email #{fetch(:lets_encrypt_email)} certonly --webroot -w #{ fetch(:pwa_root_path) } -d #{ fetch(:pwa_ssl_domains) }"
    end
  end
  
  desc "Generate PWA LetsEncrypt certificate + expand"
  task :pwa_certonly_expand do
    on release_roles fetch(:lets_encrypt_roles) do
      execute :sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto --non-interactive --agree-tos --email #{fetch(:lets_encrypt_email)} certonly --webroot -w #{ fetch(:pwa_root_path) } #{ Array(fetch(:pwa_ssl_domains)).map{ |d| "-d #{d.gsub(/^\*?\./, '')}"}.join(" ") } --expand"
    end
  end
  
end


namespace :pwa do
  
  desc "upload dist folder (BETA)"
  task :upload do
    on roles fetch(:pwa_roles) do
      local_dir = "./dist/"
      remote_dir = "#{host.user}@#{host.hostname}:#{ fetch(:pwa_root_path) }"
      
      run_locally { execute "rsync -avr --delete #{fetch(:pwa_local_path)} #{fetch(:pwa_root_path)}" }
    end
  end
  
  
end


namespace :nginx do
  
  task :load_pwa_vars do
    set :sites_available,           -> { File.join(fetch(:nginx_root_path), fetch(:nginx_sites_available)) }
    set :sites_enabled,             -> { File.join(fetch(:nginx_root_path), fetch(:nginx_sites_enabled)) }
    set :nginx_pwa_application,     -> { "pwa_#{fetch(:pwa_application)}_#{fetch(:stage)}" }
    set :enabled_pwa_application,   -> { File.join(fetch(:sites_enabled), "#{fetch(:pwa_application)}_#{fetch(:stage)}") }
    set :available_pwa_application, -> { File.join(fetch(:sites_available), "#{fetch(:pwa_application)}_#{fetch(:stage)}") }
  end
  
  namespace :pwa_site do
    
    desc 'Creates PWA site configuration and upload it to the available folder'
    task :add => ['nginx:load_pwa_vars'] do
      on release_roles fetch(:nginx_roles) do
        within fetch(:sites_available) do
          config_file = fetch(:pwa_nginx_template)
          if config_file == :default
            magic_template("nginx_pwa.conf", '/tmp/nginx_pwa.conf')
          else
            magic_template(config_file, '/tmp/nginx_pwa.conf')
          end
          execute :sudo, :mv, '/tmp/nginx_pwa.conf', fetch(:nginx_pwa_application)
        end
      end
    end
    
    desc 'Enables PWA site creating a symbolic link into the enabled folder'
    task :enable => ['nginx:load_pwa_vars'] do
      on release_roles fetch(:nginx_roles) do
        if test "! [ -h #{fetch(:enabled_pwa_application)} ]"
          within fetch(:sites_enabled) do
            execute :sudo, :ln, '-nfs', fetch(:available_pwa_application), fetch(:enabled_pwa_application)
          end
        end
      end
    end

    desc 'Disables PWA site removing the symbolic link located in the enabled folder'
    task :disable => ['nginx:load_pwa_vars'] do
      on release_roles fetch(:nginx_roles) do
        if test "[ -f #{fetch(:enabled_pwa_application)} ]"
          within fetch(:sites_enabled) do
            execute :sudo, :rm, '-f', fetch(:nginx_pwa_application)
          end
        end
      end
    end

    desc 'Removes PWA site removing the configuration file from the available folder'
    task :remove => ['nginx:load_pwa_vars'] do
      on release_roles fetch(:nginx_roles) do
        if test "[ -f #{fetch(:enabled_pwa_application)} ]"
          within fetch(:sites_available) do
            execute :sudo, :rm, fetch(:nginx_pwa_application)
          end
        end
      end
    end
    
  end
end


namespace :deploy do
  before 'deploy:restart_nginx_app', :config_pwa_nginx_app do
    if fetch(:pwa_nginx_hooks)
      invoke "nginx:pwa_site:add"
      invoke "nginx:pwa_site:enable"
    end
  end
end

