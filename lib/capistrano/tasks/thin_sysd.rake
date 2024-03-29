require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    
    set :thin_path,                   -> { '/etc/thin' }
    set :thin_roles,                  -> { :web }
    
    set :thin_timeout,                -> { 30 }
    set :thin_max_conns,              -> { 1024 }
    set :thin_max_persistent_conns,   -> { 512 }
    set :thin_require,                -> { [] }
    set :thin_wait,                   -> { 90 }
    set :thin_onebyone,               -> { true }
    # https://help.cloud66.com/rails/how-to-guides/rack-servers/thin-rack-server.html
    # You should not daemonize the custom_web process !!!
    set :thin_daemonize,              -> { false }
    set :thin_hooks,                  -> { true }
    
    set :thin_daemon_ruby_vm,         -> { :system }   # ( :rvm | :rbenv | :system )
    set :thin_daemon_file,            -> { "thin_#{fetch(:application)}_#{fetch(:stage)}" }
    set :thin_daemon_path,            -> { "/lib/systemd/system" }
    set :thin_pid_path,               -> { "/home/#{fetch(:user)}/run" }
    set :thin_daemon_template,        -> { :default }
    set :thin_daemon_log_lines,       -> { 100 }
    set :thin_daemon_user,            -> { fetch(:user, 'deploy') }  # role-user
    
  end
end


namespace :thin do
  
  def upload_thin_daemon
    if fetch(:thin_daemon_template, :default) == :default
      magic_template("thin.service", '/tmp/thin.service')
    else
      magic_template(fetch(:thin_daemon_template), '/tmp/thin.service')
    end
    execute :sudo, :mv, '/tmp/thin.service', "#{ fetch(:thin_daemon_path) }/#{ fetch(:thin_daemon_file) }.service"
  end
  
  
  ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
  ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
  
  
  desc 'Create and upload thin daemon file'
  task :upload_daemon  do
    on roles fetch(:thin_roles) do
      within current_path do
        upload_thin_daemon()
      end
    end
  end
  
  
  desc "Create and upload thin config file"
  task :reconf do
    on release_roles fetch(:thin_roles) do
      within current_path do
        magic_template("thin_app_yml", '/tmp/thin_app.yml')
        execute :sudo, :mv, '/tmp/thin_app.yml', "config/thin_app_#{fetch(:stage)}.yml"
        execute :sudo, :rm, ' -f', "#{fetch(:thin_path)}/thin_#{fetch(:application)}_#{fetch(:stage)}*"
        execute :sudo, :cp, ' -f', "#{current_path}/config/thin_app_#{fetch(:stage)}.yml", "#{shared_path}/config/thin_app_#{fetch(:stage)}.yml"
        execute :sudo, :ln, ' -sf', "#{shared_path}/config/thin_app_#{fetch(:stage)}.yml", "#{fetch(:thin_path)}/thin_#{fetch(:application)}_#{fetch(:stage)}.yml"
      end
    end
  end
  
  
  
  %w[start stop restart enable disable is-enabled].each do |cmnd|
    desc "#{cmnd.capitalize} thin service"
    task cmnd.gsub(/-/, '_') do
      on roles fetch(:thin_roles) do
        within current_path do
          execute :sudo, :systemctl, cmnd, fetch(:thin_daemon_file)
        end
      end
    end
  end
  
  desc "Quiet thin service"
  task :quiet do
    on roles fetch(:thin_roles) do
      within current_path do
        execute :sudo, :systemctl, 'kill -s TSTP', fetch(:thin_daemon_file)
      end
    end
  end
  
  desc "Get logs for thin service"
  task :logs do
    on roles fetch(:thin_roles) do
      within current_path do
        execute :sudo, :journalctl, '-u', fetch(:thin_daemon_file), '-rn', fetch(:thin_daemon_log_lines, 100)
      end
    end
  end
  
  
  desc "check thin service status"
  task :check_status do
    on roles fetch(:thin_roles) do
      within current_path do
        puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
        puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
        puts fetch(:thin_daemon_file)
        puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
        output = capture :sudo, "systemctl status", fetch(:thin_daemon_file)
        output.each_line do |line|
            puts line
        end
        puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
      end
    end
  end
  
  
end


# => after 'deploy:published', nil do
# =>   on release_roles fetch(:thin_roles) do
# =>     invoke "thin:reconf"
# =>     invoke "thin:restart"
# =>   end
# => end


namespace :deploy do
  after 'deploy:published', :restart_thin_apps do
    if fetch(:thin_hooks)
      invoke "thin:reconf"
      invoke "thin:restart"
    end
  end
end

