require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers


namespace :load do
  task :defaults do
    set :nginx_domains,               -> { [] }
    set :nginx_major_domain,          -> { false }
    set :nginx_domain_wildcard,       -> { false }
    set :nginx_redirect_subdomains,   -> { false }
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
    
    ##! depreacated!!!
    set :nginx_ssl_certificate_path,      -> { '/etc/ssl/certs' }
    set :nginx_ssl_certificate_key_path,  -> { '/etc/ssl/private' }
    set :nginx_ssl_certificate,           -> { "#{fetch(:application)}.crt" }
    set :nginx_ssl_certificate_key,       -> { "#{fetch(:application)}.key" }
    set :nginx_old_ssl_certificate,       -> { "#{fetch(:application)}.crt" }
    set :nginx_old_ssl_certificate_key,   -> { "#{fetch(:application)}.key" }
    
    ##! New-Style
    set :nginx_ssl_cert,              -> { "#{fetch(:nginx_ssl_certificate_path)}/#{fetch(:nginx_ssl_certificate)}" }
    set :nginx_ssl_key,               -> { "#{fetch(:nginx_ssl_certificate_key_path)}/#{fetch(:nginx_ssl_certificate_key)}" }
    set :nginx_other_ssl_cert,        -> { "#{fetch(:nginx_ssl_cert)}" }
    set :nginx_other_ssl_key,         -> { "#{fetch(:nginx_ssl_key)}" }
    
    set :app_server_ip,               -> { "127.0.0.1" }
    set :nginx_hooks,                 -> { true }
    ## Lets Encrypt - Challenge Path
    set :allow_well_known,            -> { false }
    ## only turn on, when rails :force_ssl is false !
    set :nginx_strict_security,       -> { false }
    
    # Diffie-Hellman settings
    set :nginx_use_diffie_hellman,    -> { false }
    ##! depreacated!!!
    set :nginx_ssl_dh_path,           -> { "/etc/ssl/certs" }
    set :nginx_ssl_dh_file,           -> { "dhparam.pem" }
    ##! New-Style
    set :nginx_diffie_hellman_param,  -> { "#{fetch(:nginx_ssl_dh_path)}/#{fetch(:nginx_ssl_dh_file)}" }
    ## SSL Cipher
    set :nginx_ssl_ciphers,           -> { "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA" }
    
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
    set :sites_available,       -> { File.join(fetch(:nginx_root_path), fetch(:nginx_sites_available)) }
    set :sites_enabled,         -> { File.join(fetch(:nginx_root_path), fetch(:nginx_sites_enabled)) }
    set :enabled_application,   -> { File.join(fetch(:sites_enabled), "#{fetch(:application)}_#{fetch(:stage)}") }
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
  
  desc "check nginx version"
  task :version do
    on release_roles fetch(:nginx_roles) do
      output = capture("nginx -v")
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
      output.each_line do |line|
          puts line
      end
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
    end
  end
  
  desc "check nginx conf"
  task :check_conf do
    nginx_service = fetch(:nginx_service_path)
    on release_roles fetch(:nginx_roles) do
      output = capture(:sudo, "nginx -t")
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
      output.each_line do |line|
          puts line
      end
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
    end
  end
  
  
  desc "check nginx service status"
  task :check_status do
    on release_roles fetch(:nginx_roles) do
      output = capture(:sudo, "systemctl status nginx.service")
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
      output.each_line do |line|
          puts line
      end
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
    end
  end
  
  
  #
  # Fix restart problems with nginx
  # https://easyengine.io/tutorials/nginx/troubleshooting/emerg-bind-failed-98-address-already-in-use/
  #
  desc "fix port Problem: 0.0.0.0:80 failed (98: Address already in use)"
  task :fix_port80 do
    on release_roles fetch(:nginx_roles) do
      execute :sudo, 'fuser -k 80/tcp'
    end
  end
  desc "fix ssl port Problem: 0.0.0.0:443 failed (98: Address already in use)"
  task :fix_port443 do
    on release_roles fetch(:nginx_roles) do
      execute :sudo, 'fuser -k 443/tcp'
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
    
    def joiner
      "\n                        "
    end
    
    def clear_domain( domain )
      "#{ domain }".gsub(/^www\./, "").gsub(/^\*?\./, "")
    end
    
    def subdomain_regex( domain )
      "~^(www\.)?(?<sub>[\w-]+)#{ Regexp.escape(".#{ domain }") }"
    end
  
    def nginx_domains
      Array( fetch(:nginx_domains) ).map{ |d| clear_domain(d) }.uniq
    end
    
    def nginx_domains_with_www
      domains = []
      nginx_domains.each do |domain|
        domains << domain
        domains << "www.#{domain}"  unless  domain =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        domains << ".#{domain}"     if      fetch(:nginx_domain_wildcard, false)
      end
      domains
    end
    
    def nginx_major_domain
      fetch(:nginx_major_domain, false) ? clear_domain( fetch(:nginx_major_domain) ) : false
    end
    
    def nginx_all_domains_with_www
      domains = []
      nginx_domains.each do |domain|
        domains << domain
        domains << "www.#{domain}"  unless  domain =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        domains << ".#{domain}"     if      fetch(:nginx_domain_wildcard, false)
      end
      if nginx_major_domain
        domains << nginx_major_domain
        domains << "www.#{nginx_major_domain}"  unless  nginx_major_domain =~ /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
        domains << ".#{nginx_major_domain}"     if      fetch(:nginx_domain_wildcard, false)
      end
      domains
    end
    
    
    
    desc 'Creates the site configuration and upload it to the available folder'
    task :add => ['nginx:load_vars'] do
      on release_roles fetch(:nginx_roles) do
        within fetch(:sites_available) do
          config_file = fetch(:nginx_template)
          if config_file == :default
            magic_template("nginx.conf", '/tmp/nginx.conf')
          else
            magic_template(config_file, '/tmp/nginx.conf')
          end
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


namespace :deploy do
  after 'deploy:finishing', :restart_nginx_app do
    if fetch(:nginx_hooks)
      invoke "nginx:site:add"
      invoke "nginx:site:enable"
      invoke "nginx:restart"
    end
  end
end

