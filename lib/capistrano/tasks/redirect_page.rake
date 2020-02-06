namespace :load do
  task :defaults do
    set :redirect_page_active,        -> { false }
    set :redirect_old_domains,        -> { [] }
    set :redirect_old_ssl_domains,    -> { [] }
    set :redirect_new_domain,         -> { '' }
    set :redirect_new_name,           -> { '' }
    set :redirect_ssl_cert,           -> { '' }
    set :redirect_ssl_key,            -> { '' }
    set :redirect_roles,              -> { :app }
    set :redirect_index_path,         -> { "redirector" }
    set :redirect_index_parent,       -> { "#{ shared_path }" }
    set :redirect_index_template,     -> { :default }
    set :redirect_nginx_template,     -> { :default }
    set :redirect_conf_name,          -> { "redirector_#{fetch(:application)}_#{fetch(:stage)}" }
  end
end

namespace :redirect_page do
  
  desc 'upload the redirect page'
  task :upload do
    on release_roles fetch(:redirect_roles) do
      within fetch(:redirect_index_parent, shared_path) do
        # create dir if not existing
        execute :mkdir, "-p #{ fetch(:redirect_index_path, 'redirector') }" 
        # upload index.html file
        config_file = fetch(:redirect_index_template, :default)
        if config_file == :default
          magic_template("redirect_page.html", '/tmp/redirect_page.html')
        else
          magic_template(config_file, '/tmp/redirect_page.html')
        end
        execute :sudo, :mv, '/tmp/redirect_page.html', "#{ fetch(:redirect_index_path, 'redirector') }/index.html"
      end
    end
  end
  
  desc 'Creates the redirect-site configuration and upload it to the available folder'
  task :add => ['nginx:load_vars'] do
    on release_roles fetch(:nginx_roles) do
      within fetch(:sites_available) do
        config_file = fetch(:redirect_nginx_template, :default)
        if config_file == :default
          magic_template("nginx_redirect_page.conf", '/tmp/nginx_redirector.conf')
        else
          magic_template(config_file, '/tmp/nginx_redirector.conf')
        end
        execute :sudo, :mv, '/tmp/nginx_redirector.conf', "#{ fetch(:redirect_conf_name) }"
      end
    end
  end

  desc 'Enables the redirect-site creating a symbolic link into the enabled folder'
  task :enable => ['nginx:load_vars'] do
    on release_roles fetch(:nginx_roles) do
      if test "! [ -h #{fetch(:sites_enabled)}/#{ fetch(:redirect_conf_name) } ]"
        within fetch(:sites_enabled) do
          execute :sudo, :ln, '-nfs', "#{fetch(:sites_available)}/#{ fetch(:redirect_conf_name) }", "#{fetch(:sites_enabled)}/#{ fetch(:redirect_conf_name) }"
        end
      end
    end
  end

  desc 'Disables the redirect-site removing the symbolic link located in the enabled folder'
  task :disable => ['nginx:load_vars'] do
    on release_roles fetch(:nginx_roles) do
      if test "[ -f #{fetch(:sites_enabled)}/#{ fetch(:redirect_conf_name) } ]"
        within fetch(:sites_enabled) do
          execute :sudo, :rm, '-f', "#{ fetch(:redirect_conf_name) }"
        end
      end
    end
  end

  desc 'Removes the redirect-site removing the configuration file from the available folder'
  task :remove => ['nginx:load_vars'] do
    on release_roles fetch(:nginx_roles) do
      if test "[ -f #{fetch(:sites_available)}/#{ fetch(:redirect_conf_name) } ]"
        within fetch(:sites_available) do
          execute :sudo, :rm, "#{ fetch(:redirect_conf_name) }"
        end
      end
    end
  end
  
  
  desc 'upload redirect-page and activate nginx config'
  task :upload_and_enable do
    invoke "redirect_page:upload"
    invoke "redirect_page:add"
    invoke "redirect_page:enable"
  end
  
  namespace :lets_encrypt do
  
    desc "Generate MONIT-WebClient LetsEncrypt certificate"
    task :certonly do
      on release_roles fetch(:lets_encrypt_roles) do
        execute :sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto --non-interactive --agree-tos --allow-subset-of-names --email #{fetch(:lets_encrypt_email)} certonly --webroot -w #{current_path}/public #{ Array(fetch(:redirect_old_ssl_domains)).map{ |d| "-d #{d.gsub(/^\*?\./, "")} -d www.#{d.gsub(/^\*?\./, "")}" }.join(" ") }"
      end
    end
  
  end
  
end





namespace :deploy do
  after :finishing, :include_redirect_page do
    if fetch(:redirect_page_active, false)
      invoke "redirect_page:upload_and_enable"
    end
  end
end