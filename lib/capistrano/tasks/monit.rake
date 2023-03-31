require 'capistrano/magic_recipes/base_helpers'
require 'capistrano/magic_recipes/sidekiq_helpers'
include Capistrano::MagicRecipes::SidekiqHelpers
include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    set :monit_roles,                 -> { :web }
    set :monit_interval,              -> { 60 }
    set :monit_bin,                   -> { '/usr/bin/monit' }
    ## Monit default:                 '/var/log/monit.log'
    set :monit_logfile,               -> { "#{shared_path}/log/monit.log" }
    set :monit_idfile,                -> { '/var/lib/monit/id' }
    set :monit_statefile,             -> { '/var/lib/monit/state' }
    ## Status
    set :monit_active,                -> { true }
    set :monit_main_rc,               -> { true }
    # set :monit_processes,             -> { %w[nginx pm2 postgresql pwa redis sidekiq thin website website_checks] }
    set :monit_processes,             -> { %w[nginx postgresql thin website] }
    set :monit_name,                  -> { "#{ fetch(:application) }_#{ fetch(:stage) }" }
    ## Mailer
    set :monit_mail_server,           -> { "smtp.gmail.com" }
    set :monit_mail_port,             -> { 587 }
    set :monit_mail_authentication,   -> { false } # SSLAUTO|SSLV2|SSLV3|TLSV1|TLSV11|TLSV12
    set :monit_mail_username,         -> { "foo@example.com" }
    set :monit_mail_password,         -> { "secret" }
    set :monit_mail_to,               -> { "foo@example.com" }
    set :monit_mail_from,             -> { "monit@foo.bar" }
    set :monit_mail_reply_to,         -> { "support@foo.bar" }
    set :monit_ignore,                -> { [] }  # %w[action pid]
    ## Additional stuff for postrgres
    set :monit_pg_pid,                -> { "/var/run/postgresql/12-main.pid" }
    ## Additional stuff for thin (need secrets_key_base to be set)
    set :monit_thin_totalmem_mb,      -> { 300 }
    set :monit_thin_pid_path,         -> { fetch(:thin_pid_path, "/home/#{fetch(:user)}/run") }
    set :thin_sysd_roles,             -> { fetch(:thin_roles) }
    ## Additional stuff for sidekiq (need secrets_key_base to be set)
    set :monit_sidekiq_totalmem_mb,   -> { 300 }
    set :monit_sidekiq_timeout_sec,   -> { 90 }
    set :monit_sidekiq_pid_path,      -> { fetch(:sidekiq_six_pid_path, "/home/#{fetch(:user)}/run") }
    ## Additional App helpers
    set :monit_app_worker_command,    -> { "cd #{ current_path } ; #{fetch(:rvm_path)}/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec MONIT_CMD" }
    set :monit_app_worker_role,       -> { :user }  # user / bash / shell
    set :monit_app_worker_prefix,     -> { :rvm }   # rvm / rvm1capistrano3 / env
    ## WebClient
    set :monit_http_client,           -> { true }
    set :monit_http_port,             -> { 2812 }
    set :monit_http_username,         -> { "admin" }
    set :monit_http_password,         -> { "monitor" }
    # use a subdomain for monit?
    set :monit_webclient,             -> { false }
    set :monit_webclient_domain,      -> { false }
    set :monit_webclient_use_ssl,     -> { false }
    set :monit_webclient_ssl_cert,    -> { false }
    set :monit_webclient_ssl_key,     -> { false }
    set :monit_nginx_template,        -> { :default }
    ## Website
    set :monit_website_check_name,    -> { "#{fetch(:application)}-#{fetch(:stage)}" }
    set :monit_website_check_timeout, -> { 10 }
    set :monit_website_check_cycles,  -> { 3 }
    set :monit_website_check_content, -> { false }
    set :monit_website_check_path,    -> { "/" }
    set :monit_website_check_text,    -> { "<!DOCTYPE html>" }
    ## check other Sites:
    set :monit_websites_to_check,     -> { [] }
    # Website: { name: String, domain: String, ssl: Boolean, check_content: Boolean, path: String, content: String }
    
    ## M/Monit
    set :monit_mmonit_url,            -> { false }
    
    ## PM2 - JS - App
    set :monit_pm2_app_name,          -> { "app" }
    set :monit_pm2_app_instances,     -> { 1 }
    set :monit_pm2_app_path,          -> { "/home/#{fetch(:user)}/pm2_app" }
    set :monit_pm2_pid_path,          -> { "/home/#{fetch(:user)}/.pm2/pids" }
    set :monit_pm2_start_script,      -> { "ecosystem.config.js" }
    set :monit_pm2_stage,             -> { "production" }
    set :pm2_roles,                   -> { :web }
    set :monit_pm2_worker_role,       -> { :user }
    set :monit_pm2_worker_prefix,     -> { "" }
    set :monit_pm2_check_website,     -> { false }
    set :monit_pm2_website_name,      -> { "PM2 #{fetch(:application)} #{fetch(:stage)}" }
    set :monit_pm2_website_url,       -> { "example.com" }
    set :monit_pm2_website_ssl,       -> { false }
    
    
  end
end

namespace :monit do
  desc "Install Monit"
  task :install do
    on release_roles fetch(:monit_roles) do
      execute :sudo, "apt-get update"
      execute :sudo, "apt-get -y install monit"
    end
  end
  # after "deploy:install", "monit:install"

  desc "Setup all Monit configuration"
  task :setup do
    on release_roles fetch(:monit_roles) do
      if fetch(:monit_main_rc, false)
        monit_config "monitrc", "/etc/monit/monitrc"
      end
      # invoke "monit:nginx"
      # invoke "monit:postgresql"
      # invoke "monit:sidekiq"
      # invoke "monit:redis"
      # invoke "monit:thin"
      # invoke "monit:configure_website"
      %w[nginx pm2 postgresql pwa redis sidekiq sidekiq_six thin thin_sysd website website_checks].each do |command|
        invoke "monit:#{command}:configure" if Array(fetch(:monit_processes)).include?(command)
      end
      if fetch(:monit_webclient, false) && fetch(:monit_webclient_domain, false)
        invoke "nginx:monit:add"
        invoke "nginx:monit:enable"
      end
    end
    invoke "monit:syntax"
    invoke "monit:reload"
  end
  # after "deploy:setup", "monit:setup"
  
  desc 'Downgrade MONIT to 5.16 (fix action problem)'
  task :downgrade_system do
    on roles :db do
      execute :sudo, 'apt-get -y install monit=1:5.16-2 --allow-downgrades'
    end
  end
  
  %w[nginx pm2 postgresql redis sidekiq sidekiq_six thin thin_sysd].each do |process|
    namespace process.to_sym do
      
      %w[monitor unmonitor start stop restart].each do |command|
        desc "#{command} monit-service for: #{process}"
        task "#{command}" do
          if Array(fetch(:monit_processes)).include?(process)
            on roles(fetch("#{process}_roles".to_sym)) do
              if process == "sidekiq"
                # fetch(:sidekiq_processes)
                sidekiq_processes_count.times do |idx|
                  sudo "#{fetch(:monit_bin)} #{command} #{sidekiq_service_name(idx)}"
                end
              elsif process == "thin"
                fetch(:app_instances).times do |idx|
                  sudo "#{fetch(:monit_bin)} #{command} #{fetch(:application)}_#{fetch(:stage)}_thin_#{idx}"
                end
              elsif process == "pm2"
                fetch(:monit_pm2_app_instances).times do |idx|
                  sudo "#{fetch(:monit_bin)} #{command} #{fetch(:application)}_#{fetch(:stage)}_pm2_#{idx}"
                end
              else
                sudo "#{fetch(:monit_bin)} #{command} #{process}"
              end
            end
          end
        end
      end
      
      if %w[nginx postgresql redis].include?(process)
        ## Server specific tasks (gets overwritten by other environments!)
        desc "Upload Monit #{process} config file (server specific)"
        task "configure" do
          if Array(fetch(:monit_processes)).include?(process)
            on release_roles fetch("#{process}_roles".to_sym) do |role|
              monit_config( process, nil, role )
            end
          end
        end
      elsif %w[pm2 pwa sidekiq thin sidekiq_six thin_sysd].include?(process)
        ## App specific tasks (unique for app and environment)
        desc "Upload Monit #{process} config file (app specific)"
        task "configure" do
          puts "configure: #{process}"
          puts ":monit_processes: #{ Array(fetch(:monit_processes)) }"
          if Array(fetch(:monit_processes)).include?(process)
            on release_roles fetch("#{process}_roles".to_sym) do |role|
              monit_config process, "/etc/monit/conf.d/#{fetch(:application)}_#{fetch(:stage)}_#{process}.conf", role
            end
          end
        end
      end
      
    end
  end
  
  %w[pwa website website_checks].each do |process|
    namespace process.to_sym do
      
      desc "Upload Monit #{process} config file (app specific)"
      task "configure" do
        if Array(fetch(:monit_processes)).include?(process)
          on release_roles fetch("#{process =~ /website/ ? 'nginx' : process}_roles".to_sym, :web) do |role|
            monit_config process, "/etc/monit/conf.d/#{fetch(:application)}_#{fetch(:stage)}_#{process}.conf", role
          end
        end
      end
      
    end
  end
  
  
  

  %w[start stop restart syntax reload].each do |command|
    desc "Run Monit #{command} script"
    task command do
      on release_roles fetch(:monit_roles) do
        execute :sudo, :service, :monit, "#{command}"
      end
    end
  end
  
  def sidekiq_service_name(index=nil)
    fetch(:sidekiq_service_name, "#{fetch(:application)}_#{fetch(:stage)}_sidekiq_") + index.to_s
  end
  
  def sidekiq_six_service_name(service_file)
    "#{fetch(:application)}_#{fetch(:stage)}_sidekiq_#{ service_file.split('-').last }"
  end
  
end

def monit_config( name, destination = nil, role = nil )
  @role = role
  destination ||= "/etc/monit/conf.d/#{name}.conf"
  template_with_role "monit/#{name}", "/tmp/monit_#{name}", @role
  execute :sudo, "mv /tmp/monit_#{name} #{destination}"
  execute :sudo, "chown root #{destination}"
  execute :sudo, "chmod 600 #{destination}"
end

def monit_role_prefix( role )
  case role.to_s.downcase.strip
  when "sh", "shell"
    "/bin/sh -c 'REAL_COMMAND_HERE'"
  when "bash"
    "/bin/bash -c 'REAL_COMMAND_HERE'"
  else
    "/bin/su - #{fetch(:user)} -c 'REAL_COMMAND_HERE'"
  end
end

def monit_app_prefixed( cmd )
  # fetch(:monit_app_worker_command, "cd #{ current_path } ; bundle exec MONIT_CMD").to_s.gsub(/MONIT_CMD/, cmd)
  komando = monit_role_prefix( fetch(:monit_app_worker_role, :user) )
  
  case fetch(:monit_app_worker_prefix, :env).to_s.downcase.strip
  when "rvm"
    komando.gsub!(/REAL_COMMAND_HERE/, "cd #{ current_path } ; #{fetch(:rvm_path)}/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec MONIT_CMD")
  when "rvm1capistrano3", "rvm1capistrano", "rvm1"
    komando.gsub!(/REAL_COMMAND_HERE/, "cd #{ current_path } ; #{fetch(:rvm1_auto_script_path)}/rvm-auto.sh #{fetch(:rvm1_ruby_version)} bundle exec MONIT_CMD")
  else
    komando.gsub!(/REAL_COMMAND_HERE/, "/usr/bin/env cd #{current_path} ; bundle exec MONIT_CMD")
  end
  
  komando.gsub(/MONIT_CMD/, cmd)
end

def monit_pm2_prefixed( cmd )
  # fetch(:monit_app_worker_command, "cd #{ current_path } ; bundle exec MONIT_CMD").to_s.gsub(/MONIT_CMD/, cmd)
  komando = monit_role_prefix( fetch(:monit_pm2_worker_role, :user) )
  komando.gsub!(/REAL_COMMAND_HERE/, "cd #{fetch(:monit_pm2_app_path)} ; #{fetch(:monit_pm2_worker_prefix, '')} MONIT_CMD")
  komando.gsub(/MONIT_CMD/, cmd)
end




def init_site_check_item( domain )
  ## defaults
  that = { ssl: false, check_content: false, path: '/', content: '<!DOCTYPE html>', timeout: 30, cycles: 3 }
  that.merge! domain
  that[:name] = that[:domain]   if [nil, '', ' '].include?( that[:name] )
  that
end

def monit_website_list
  Array( fetch(:monit_websites_to_check) ).map{ |d| init_site_check_item(d) }
end




namespace :nginx do
  namespace :monit do
    
    desc 'Creates MONIT WebClient configuration and upload it to the available folder'
    task :add => ['nginx:load_vars'] do
      on release_roles fetch(:nginx_roles) do
        within fetch(:sites_available) do
          config_file = fetch(:monit_nginx_template, :default)
          if config_file == :default
            magic_template("nginx_monit.conf", '/tmp/nginx_monit.conf')
          else
            magic_template(config_file, '/tmp/nginx_monit.conf')
          end
          execute :sudo, :mv, '/tmp/nginx_monit.conf', "monit_webclient"
        end
      end
    end
    
    desc 'Enables MONIT WebClient creating a symbolic link into the enabled folder'
    task :enable => ['nginx:load_vars'] do
      on release_roles fetch(:nginx_roles) do
        if test "! [ -h #{ File.join(fetch(:sites_enabled), "monit_webclient") } ]"
          within fetch(:sites_enabled) do
            execute :sudo, :ln, '-nfs', File.join(fetch(:sites_available), "monit_webclient"), "monit_webclient"
          end
        end
      end
    end

    desc 'Disables MONIT WebClient removing the symbolic link located in the enabled folder'
    task :disable => ['nginx:load_vars'] do
      on release_roles fetch(:nginx_roles) do
        if test "[ -f #{ File.join(fetch(:sites_enabled), "monit_webclient") } ]"
          within fetch(:sites_enabled) do
            execute :sudo, :rm, '-f', "monit_webclient"
          end
        end
      end
    end
    
  end
end

namespace :lets_encrypt do
  
  desc "Generate MONIT-WebClient LetsEncrypt certificate"
  task :monit_certonly do
    on release_roles fetch(:lets_encrypt_roles) do
      if fetch(:lets_encrypt_client) == "certbot-auto"
        execute :sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto --non-interactive --agree-tos --email #{fetch(:lets_encrypt_email)} certonly --webroot -w #{current_path}/public -d #{ fetch(:monit_webclient_domain).gsub(/^\*?\./, '') }"
      else
        execute :sudo, "certbot --non-interactive --agree-tos --email #{fetch(:lets_encrypt_email)} certonly --webroot -w #{current_path}/public -d #{ fetch(:monit_webclient_domain).gsub(/^\*?\./, '') }"
      end
    end
  end
  
end


namespace :deploy do
  before :starting, :stop_monitoring do
    invoke "monit:downgrade_system" if fetch(:monit_downgrade_on_deploy, false)
    %w[sidekiq thin].each do |command|
      if fetch(:monit_active) && Array(fetch(:monit_processes)).include?(command)
        invoke "monit:unmonitor_#{command}"
      end
    end
  end
  # after :finished, :setup_monit_configs do
  #   invoke "monit:setup" if fetch(:monit_active)
  # end
  before 'deploy:finishing', :add_monit_webclient do
    if fetch(:monit_webclient, false) && fetch(:monit_webclient_domain, false)
      invoke "nginx:monit:add"
      invoke "nginx:monit:enable"
    end
  end
  after :finished, :restart_monitoring do
    %w[sidekiq thin].each do |command|
      if fetch(:monit_active) && Array(fetch(:monit_processes)).include?(command)
        invoke "monit:monitor_#{command}"
      end
    end
  end
end

desc 'Server setup tasks'
task :setup do
  invoke "monit:setup" if fetch(:monit_active)
end
