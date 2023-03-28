require 'capistrano/magic_recipes/sidekiq_helpers'
include Capistrano::MagicRecipes::SidekiqHelpers

##
## NEW!   for sidekiqs new deamonized style
##

# https://github.com/seuros/capistrano-sidekiq
namespace :load do
  task :defaults do
    set :sidekiq_six_default_hooks,     -> { true }
    set :sidekiq_six_deamon_file,       -> { "sidekiq_#{fetch(:application)}_#{fetch(:stage)}" }
    set :sidekiq_six_timeout,           -> { 10 }
    set :sidekiq_six_roles,             -> { :app }
    set :sidekiq_six_processes,         -> { 1 }
    # Sidekiq queued processes:
    
    set :sidekiq_six_special_queues,    -> { false }
    set :sidekiq_six_queued_processes,  -> { [] }
    ## If needed you can set special queues and configure it seperately
    ## .. options:  
    ##    - queue:      string    # => queue-name       (default: "default")
    ##    - processes:  integer   # => number processes (default: 1)
    ##    - worker:     integer   # => concurrency      (default: 7)
    ## => [ { queue: "queue_name", processes: "count", worker: "count" }]
    
    set :sidekiq_six_deamon_path,       -> { "/lib/systemd/system" }
    set :sidekiq_six_deamon_template,   -> { :default }
    
    set :sidekiq_six_ruby_vm,           -> { :system }   # ( :rvm | :rbenv | :system )
    
    set :sidekiq_six_user,              -> { fetch(:user, 'deploy') }   # role-user
    set :sidekiq_six_log_lines,         -> { 100 }
    
  end
end


namespace :sidekiq_six do
  
  
  
  def upload_deamon(service_file, idx = 0)
    args = []
    args.push "--environment #{fetch(:stage)}"
    args.push "--require #{fetch(:sidekiq_six_require)}" if fetch(:sidekiq_six_require)
    args.push "--tag #{fetch(:sidekiq_six_tag)}" if fetch(:sidekiq_six_tag)
    if fetch(:sidekiq_six_special_queues)
      queue_config = sidekiq_special_config(idx)
      args.push "--queue #{ queue_config[:queue] || 'default' }"
      args.push "--concurrency #{ queue_config[:concurrency] || 7 }"
    else
      Array(fetch(:sidekiq_six_queue)).each do |queue|
        args.push "--queue #{queue}"
      end
      args.push "--concurrency #{fetch(:sidekiq_six_concurrency)}" if fetch(:sidekiq_six_concurrency)
    end
    args.push "--config #{fetch(:sidekiq_six_config)}" if fetch(:sidekiq_six_config)
    # use sidekiq_options for special options
    args.push fetch(:sidekiq_six_options) if fetch(:sidekiq_six_options)

    side_kiq_args = args.compact.join(' ')
    
    @service_file   = service_file
    @side_kiq_args  = side_kiq_args
    
    if fetch(:sidekiq_six_deamon_template, :default) == :default
      magic_template("sidekiq.service", '/tmp/sidekiq.service')
    else
      magic_template(fetch(:sidekiq_six_deamon_template), '/tmp/sidekiq.service')
    end
    execute :sudo, :mv, '/tmp/sidekiq.service', "#{ fetch(:sidekiq_six_deamon_path) }/#{ service_file }.service"
  end
  
  
  ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
  ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
  
  
  desc 'Creates and uploads sidekiq6 DEAMON files'
  task :upload_deamons  do
    on roles fetch(:sidekiq_six_roles) do
      for_each_process do |service_file, idx|
        upload_deamon(service_file, idx)
      end
    end
  end
  
  %w[start stop restart enable disable is-enabled].each do |cmnd|
    desc "#{cmnd.capitalize} sidekiq6 service"
    task cmnd.gsub(/-/, '_') do
      on roles fetch(:sidekiq_six_roles) do
        for_each_process do |service_file, idx|
          execute :sudo, :systemctl, cmnd, service_file
        end
      end
    end
  end
  
  desc "Quiet sidekiq6 service"
  task :quiet do
    on roles fetch(:sidekiq_six_roles) do
      for_each_process do |service_file, idx|
        execute :sudo, :systemctl, 'kill -s TSTP', service_file
      end
    end
  end
  
  desc "Get logs for sidekiq6 service"
  task :logs do
    on roles fetch(:sidekiq_six_roles) do
      for_each_process do |service_file, idx|
        execute :sudo, :journalctl, '-u', service_file, '-rn', fetch(:sidekiq_six_log_lines, 100)
      end
    end
  end
  
  
  desc "check sidekiq6 service status"
  task :check_status do
    on roles fetch(:sidekiq_six_roles) do
      for_each_process do |service_file, idx|
        puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
        puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
        puts service_file
        puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
        output = capture :sudo, "systemctl status", service_file
        output.each_line do |line|
            puts line
        end
        puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
      end
    end
  end
  
  
end


namespace :deploy do
  before :starting, :stop_sidekiq_services do
    if fetch(:sidekiq_six_default_hooks)
      invoke "sidekiq_six:stop"
    end
  end
  after :finished, :restart_sidekiq_services do
    if fetch(:sidekiq_six_default_hooks)
      invoke "sidekiq_six:start"
    end
  end
end