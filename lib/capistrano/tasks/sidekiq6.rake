##
## NEW!   for sidekiqs new deamonized style
##

# https://github.com/seuros/capistrano-sidekiq
namespace :load do
  task :defaults do
    set :sidekiq6_default_hooks,     -> { true }
    set :sidekiq6_deamon_file,       -> { "sidekiq_#{fetch(:application)}_#{fetch(:stage)}" }
    set :sidekiq6_timeout,           -> { 10 }
    set :sidekiq6_roles,             -> { :app }
    set :sidekiq6_processes,         -> { 1 }
    # Sidekiq queued processes:
    
    set :sidekiq6_special_queues,    -> { false }
    set :sidekiq6_queued_processes,  -> { [] }
    ## If needed you can set special queues and configure it seperately
    ## .. options:  
    ##    - queue:      string    # => queue-name       (default: "default")
    ##    - processes:  integer   # => number processes (default: 1)
    ##    - worker:     integer   # => concurrency      (default: 7)
    ## => [ { queue: "queue_name", processes: "count", worker: "count" }]
    
    set :sidekiq6_deamon_path,       -> { "/lib/systemd/system" }
    set :sidekiq6_deamon_template,   -> { :default }
    
    set :sidekiq6_ruby_vm,           -> { :system }   # ( :rvm | :rbenv | :system )
    
  end
end


namespace :sidekiq6 do
  
  def for_each_process(reverse = false, &block)
    pids = processes_deamones
    pids.reverse! if reverse
    pids.each_with_index do |service_file, idx|
      within fetch(:sidekiq6_deamon_path) do
        yield(service_file, idx)
      end
    end
  end
  
  def processes_deamones
    deamons = []
    if fetch(:sidekiq6_special_queues)
      fetch(:sidekiq6_queued_processes, []).each do |qp|
        counter = (qp[:processes] && qp[:processes].to_i > 0 ? qp[:processes].to_i : 1)
        if counter > 1
          counter.times do |idx|
            deamons.push "#{ fetch(:sidekiq6_deamon_file) }-#{ qp[:queue] }-#{ idx }"
          end
        else
          deamons.push "#{ fetch(:sidekiq6_deamon_file) }-#{ qp[:queue] }"
        end
      end
    else
      counter = fetch(:sidekiq6_processes).to_i 
      if counter > 1
        counter.times do |idx|
          deamons.push "#{ fetch(:sidekiq6_deamon_file) }-#{ idx }"
        end
      else
        deamons.push "#{ fetch(:sidekiq6_deamon_file) }"
      end
    end
    deamons
  end
  
  def sidekiq_special_config(idx)
    if fetch(:sidekiq6_special_queues)
      settingz = []
      fetch(:sidekiq6_queued_processes).each do |that|
        (that[:processes] && that[:processes].to_i > 0 ? that[:processes].to_i : 1 ).to_i.times do
          sttng_hash = {}
          sttng_hash[:queue] = that[:queue] ? that[:queue] : "default"
          sttng_hash[:concurrency] = that[:worker] && that[:worker].to_i > 0 ? that[:worker].to_i : 7
          settingz.push( sttng_hash )
        end
      end
      settingz[ idx.to_i ]
    else
      {}
    end
  end
  
  def upload_deamon(service_file, idx = 0)
    args = []
    args.push "--index #{idx}"
    args.push "--environment #{fetch(:stage)}"
    args.push "--require #{fetch(:sidekiq6_require)}" if fetch(:sidekiq6_require)
    args.push "--tag #{fetch(:sidekiq6_tag)}" if fetch(:sidekiq6_tag)
    if fetch(:sidekiq6_special_queues)
      queue_config = sidekiq_special_config(idx)
      args.push "--queue #{ queue_config[:queue] || 'default' }"
      args.push "--concurrency #{ queue_config[:concurrency] || 7 }"
    else
      Array(fetch(:sidekiq6_queue)).each do |queue|
        args.push "--queue #{queue}"
      end
      args.push "--concurrency #{fetch(:sidekiq6_concurrency)}" if fetch(:sidekiq6_concurrency)
    end
    args.push "--config #{fetch(:sidekiq6_config)}" if fetch(:sidekiq6_config)
    # use sidekiq_options for special options
    args.push fetch(:sidekiq6_options) if fetch(:sidekiq6_options)

    side_kiq_args = args.compact.join(' ')
    
    if fetch(:sidekiq6_deamon_template, :default) == :default
      magic_template("sidekiq.service", '/tmp/sidekiq.service')
    else
      magic_template(fetch(:sidekiq6_deamon_template), '/tmp/sidekiq.service')
    end
    execute :sudo, :mv, '/tmp/sidekiq.service', "#{ fetch(:sidekiq6_deamon_path) }/#{ service_file }.service"
  end
  
  
  ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
  ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### 
  
  
  desc 'Creates and uploads sidekiq6 DEAMON files'
  task :upload_deamons  do
    on roles fetch(:sidekiq6_roles) do
      for_each_process do |service_file, idx|
        upload_deamon(service_file, idx)
      end
    end
  end
  
  %w[start stop restart enable disable is-enabled].each do |command|
    desc "#{command.capitalize} sidekiq6 service"
    task command.gsub(/-/, '_') do
      on roles fetch(:sidekiq6_roles) do
        for_each_process do |service_file, idx|
          execute :systemctl, command, service_file
        end
      end
    end
  end
  
  desc "Quiet sidekiq6 service"
  task command do
    on roles fetch(:sidekiq6_roles) do
      for_each_process do |service_file, idx|
        execute :systemctl, 'kill -s TSTP', service_file
      end
    end
  end
  
  
  desc "check sidekiq6 service status"
  task :check_status do
    on roles fetch(:sidekiq6_roles) do
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
    if fetch(:sidekiq6_default_hooks)
      invoke "sidekiq6:stop"
    end
  end
  after :finished, :restart_sidekiq_services do
    if fetch(:sidekiq6_default_hooks)
      invoke "sidekiq6:start"
    end
  end
end