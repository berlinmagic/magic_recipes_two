require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    set :monit_roles,                 -> { :web }
    set :monit_interval,              -> { 30 }
    set :monit_bin,                   -> { '/usr/bin/monit' }
    ## Monit default:                 '/var/log/monit.log'
    set :monit_logfile,               -> { "#{shared_path}/log/monit.log" }
    set :monit_idfile,                -> { '/var/lib/monit/id' }
    set :monit_statefile,             -> { '/var/lib/monit/state' }
    ## Status
    set :monit_active,                -> { true }
    # set :monit_processes,             -> { %w[nginx postgresql redis sidekiq thin website] }
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
    ## Additional stuff for postrgres
    set :postgresql_roles,            -> { :db }
    set :postgresql_pid,              -> { "/var/run/postgresql/9.1-main.pid" }
    ## Additional stuff for thin (need secrets_key_base to be set)
    set :monit_thin_with_secret,      -> { false }
    set :monit_thin_totalmem_mb,      -> { 300 }
    ## Additional stuff for sidekiq (need secrets_key_base to be set)
    set :monit_sidekiq_with_secret,   -> { false }
    set :monit_sidekiq_totalmem_mb,   -> { 300 }
    set :monit_sidekiq_timeout_sec,   -> { 90 }
    ## WebClient
    set :monit_http_client,           -> { true }
    set :monit_http_domain,           -> { false }
    set :monit_http_port,             -> { 2812 }
    set :monit_http_use_ssl,          -> { false }
    set :monit_http_allow_self_certification, -> { false }
    set :monit_http_pemfile,          -> { "/etc/monit/monit.pem" }
    set :monit_http_username,         -> { "admin" }
    set :monit_http_password,         -> { "monitor" }
    ## Website
    set :monit_website_check_timeout, -> { 10 }
    set :monit_website_check_cycles,  -> { 3 }
    set :monit_website_check_content, -> { false }
    set :monit_website_check_path,    -> { "/" }
    set :monit_website_check_text,    -> { "<!DOCTYPE html>" }
    ## M/Monit
    set :monit_mmonit_url,            -> { false }
    
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
      monit_config "monitrc", "/etc/monit/monitrc"
      # invoke "monit:nginx"
      # invoke "monit:postgresql"
      # invoke "monit:sidekiq"
      # invoke "monit:redis"
      # invoke "monit:thin"
      # invoke "monit:configure_website"
      %w[nginx postgresql redis sidekiq thin website].each do |command|
        invoke "monit:configure_#{command}" if Array(fetch(:monit_processes)).include?(command)
      end
    end
    invoke "monit:syntax"
    invoke "monit:reload"
  end
  # after "deploy:setup", "monit:setup"
  
  
  %w[nginx postgresql redis sidekiq thin].each do |process|
      
      %w[monitor unmonitor start stop restart].each do |command|
        desc "#{command} monit-service for: #{process}"
        task "#{command}_#{process}" do
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
        task "configure_#{process}" do
          if Array(fetch(:monit_processes)).include?(process)
            on release_roles fetch("#{process}_roles".to_sym) do |role|
              monit_config( process, nil, role )
            end
          end
        end
      elsif %w[sidekiq thin].include?(process)
        ## App specific tasks (unique for app and environment)
        desc "Upload Monit #{process} config file (app specific)"
        task "configure_#{process}" do
          if Array(fetch(:monit_processes)).include?(process)
            on release_roles fetch("#{process}_roles".to_sym) do |role|
              monit_config process, "/etc/monit/conf.d/#{fetch(:application)}_#{fetch(:stage)}_#{process}.conf", role
            end
          end
        end
      end
      
  end
  
  
  desc "Upload Monit website config file (app specific)"
  task "configure_website" do
    if Array(fetch(:monit_processes)).include?("website")
      on release_roles fetch(:nginx_roles, :web) do |role|
        monit_config "website", "/etc/monit/conf.d/#{fetch(:application)}_#{fetch(:stage)}_website.conf", role
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
  
end

def monit_config( name, destination = nil, role = nil )
  @role = role
  destination ||= "/etc/monit/conf.d/#{name}.conf"
  template_with_role "monit/#{name}", "/tmp/monit_#{name}", @role
  execute :sudo, "mv /tmp/monit_#{name} #{destination}"
  execute :sudo, "chown root #{destination}"
  execute :sudo, "chmod 600 #{destination}"
end


namespace :deploy do
  before :starting, :stop_monitoring do
    %w[sidekiq thin].each do |command|
      if fetch(:monit_active) && Array(fetch(:monit_processes)).include?(command)
        invoke "monit:unmonitor_#{command}"
      end
    end
  end
  # after :finished, :setup_monit_configs do
  #   invoke "monit:setup" if fetch(:monit_active)
  # end
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
