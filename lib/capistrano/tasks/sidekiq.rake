# https://github.com/seuros/capistrano-sidekiq
namespace :load do
  task :defaults do
    set :sidekiq_default_hooks, -> { true }

    set :sidekiq_pid,               -> { File.join(shared_path, 'pids', 'sidekiq.pid') }
    set :sidekiq_env,               -> { fetch(:rack_env, fetch(:rails_env, fetch(:stage))) }
    set :sidekiq_log,               -> { File.join(shared_path, 'log', 'sidekiq.log') }
    set :sidekiq_timeout,           -> { 10 }
    set :sidekiq_roles,             -> { :app }
    set :sidekiq_processes,         -> { 1 }
    # Sidekiq queued processes:
    
    set :sidekiq_special_queues,    -> { false }
    set :sidekiq_queued_processes,  -> { [] }
    ## If needed you can set special queues and configure it seperately
    ## .. options:  
    ##    - queue:      string    # => queue-name       (default: "default")
    ##    - processes:  integer   # => number processes (default: 1)
    ##    - worker:     integer   # => concurrency      (default: 7)
    ## => [ { queue: "queue_name", processes: "count", worker: "count" }]
    
    # Rbenv and RVM integration
    set :rbenv_map_bins, fetch(:rbenv_map_bins).to_a.concat(%w(sidekiq sidekiqctl))
    set :rvm_map_bins, fetch(:rvm_map_bins).to_a.concat(%w(sidekiq sidekiqctl))
  end
end


namespace :deploy do
  before :starting, :check_sidekiq_hooks do
    invoke 'sidekiq:add_default_hooks' if fetch(:sidekiq_default_hooks)
  end
  after :publishing, :restart_sidekiq do
    invoke 'sidekiq:restart' if fetch(:sidekiq_default_hooks)
  end
end


namespace :sidekiq do
  def for_each_process(reverse = false, &block)
    pids = processes_pids
    pids.reverse! if reverse
    pids.each_with_index do |pid_file, idx|
      within current_path do
        yield(pid_file, idx)
      end
    end
  end
  
  def sidekiq_special_config(idx)
    if fetch(:sidekiq_special_queues)
      settingz = []
      fetch(:sidekiq_queued_processes).each do |that|
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

  def processes_pids
    pids = []
    if fetch(:sidekiq_special_queues)
      # processes_count = fetch(:sidekiq_queued_processes).sum{ |qp| qp[:processes].present? ? qp[:processes].to_i : 1 }
      processes_count = fetch(:sidekiq_queued_processes).inject(0){ |sum,qp| sum + (qp[:processes] && qp[:processes].to_i > 0 ? qp[:processes].to_i : 1) }
      processes_count.times do |idx|
        pids.push (idx.zero? && processes_count <= 1) ?
                      fetch(:sidekiq_pid) :
                      fetch(:sidekiq_pid).gsub(/\.pid$/, "-#{idx}.pid")

      end
    else
      fetch(:sidekiq_processes).times do |idx|
        pids.push (idx.zero? && fetch(:sidekiq_processes) <= 1) ?
                      fetch(:sidekiq_pid) :
                      fetch(:sidekiq_pid).gsub(/\.pid$/, "-#{idx}.pid")

      end
    end
    pids
  end

  def pid_process_exists?(pid_file)
    pid_file_exists?(pid_file) and test(*("kill -0 $( cat #{pid_file} )").split(' '))
  end

  def pid_file_exists?(pid_file)
    test(*("[ -f #{pid_file} ]").split(' '))
  end

  def stop_sidekiq(pid_file)
    if fetch(:stop_sidekiq_in_background, fetch(:sidekiq_run_in_background))
      if fetch(:sidekiq_use_signals)
        background "kill -TERM `cat #{pid_file}`"
      else
        background :bundle, :exec, :sidekiqctl, 'stop', "#{pid_file}", fetch(:sidekiq_timeout)
      end
    else
      execute :bundle, :exec, :sidekiqctl, 'stop', "#{pid_file}", fetch(:sidekiq_timeout)
    end
  end

  def quiet_sidekiq(pid_file)
    if fetch(:sidekiq_use_signals)
      background "kill -USR1 `cat #{pid_file}`"
    else
      begin
        execute :bundle, :exec, :sidekiqctl, 'quiet', "#{pid_file}"
      rescue SSHKit::Command::Failed
        # If gems are not installed eq(first deploy) and sidekiq_default_hooks as active
        warn 'sidekiqctl not found (ignore if this is the first deploy)'
      end
    end
  end

  def start_sidekiq(pid_file, idx = 0)
    args = []
    args.push "--index #{idx}"
    args.push "--pidfile #{pid_file}"
    args.push "--environment #{fetch(:sidekiq_env)}"
    args.push "--logfile #{fetch(:sidekiq_log)}" if fetch(:sidekiq_log)
    args.push "--require #{fetch(:sidekiq_require)}" if fetch(:sidekiq_require)
    args.push "--tag #{fetch(:sidekiq_tag)}" if fetch(:sidekiq_tag)
    if fetch(:sidekiq_special_queues)
      queue_config = sidekiq_special_config(idx)
      args.push "--queue #{ queue_config[:queue] || 'default' }"
      args.push "--concurrency #{ queue_config[:concurrency] || 7 }"
    else
      Array(fetch(:sidekiq_queue)).each do |queue|
        args.push "--queue #{queue}"
      end
      args.push "--concurrency #{fetch(:sidekiq_concurrency)}" if fetch(:sidekiq_concurrency)
    end
    args.push "--config #{fetch(:sidekiq_config)}" if fetch(:sidekiq_config)
    # use sidekiq_options for special options
    args.push fetch(:sidekiq_options) if fetch(:sidekiq_options)

    if defined?(JRUBY_VERSION)
      args.push '>/dev/null 2>&1 &'
      warn 'Since JRuby doesn\'t support Process.daemon, Sidekiq will not be running as a daemon.'
    else
      args.push '--daemon'
    end

    if fetch(:start_sidekiq_in_background, fetch(:sidekiq_run_in_background))
      background :bundle, :exec, :sidekiq, args.compact.join(' ')
    else
      execute :bundle, :exec, :sidekiq, args.compact.join(' ')
    end
  end

  task :add_default_hooks do
    after 'deploy:starting', 'sidekiq:quiet'
    after 'deploy:updated', 'sidekiq:stop'
    after 'deploy:reverted', 'sidekiq:stop'
    after 'deploy:published', 'sidekiq:start'
  end

  desc 'Quiet sidekiq (stop processing new tasks)'
  task :quiet do
    on roles fetch(:sidekiq_roles) do
      if test("[ -d #{current_path} ]") # fixes #11
        for_each_process(true) do |pid_file, idx|
          if pid_process_exists?(pid_file)
            quiet_sidekiq(pid_file)
          end
        end
      end
    end
  end

  desc 'Stop sidekiq'
  task :stop do
    on roles fetch(:sidekiq_roles) do
      if test("[ -d #{current_path} ]")
        for_each_process(true) do |pid_file, idx|
          if pid_process_exists?(pid_file)
            stop_sidekiq(pid_file)
          end
        end
      end
    end
  end

  desc 'Start sidekiq'
  task :start do
    on roles fetch(:sidekiq_roles) do
      for_each_process do |pid_file, idx|
        start_sidekiq(pid_file, idx) unless pid_process_exists?(pid_file)
      end
    end
  end

  desc 'Restart sidekiq'
  task :restart do
    invoke 'sidekiq:stop'
    invoke 'sidekiq:start'
  end

  desc 'Rolling-restart sidekiq'
  task :rolling_restart do
    on roles fetch(:sidekiq_roles) do
      for_each_process(true) do |pid_file, idx|
        if pid_process_exists?(pid_file)
          stop_sidekiq(pid_file)
        end
        start_sidekiq(pid_file, idx)
      end
    end
  end

  # Delete any pid file not in use
  task :cleanup do
    on roles fetch(:sidekiq_roles) do
      for_each_process do |pid_file, idx|
        if pid_file_exists?(pid_file)
          execute "rm #{pid_file}" unless pid_process_exists?(pid_file)
        end
      end
    end
  end

  # TODO : Don't start if all proccess are off, raise warning.
  desc 'Respawn missing sidekiq proccesses'
  task :respawn do
    invoke 'sidekiq:cleanup'
    on roles fetch(:sidekiq_roles) do
      for_each_process do |pid_file, idx|
        unless pid_file_exists?(pid_file)
          start_sidekiq(pid_file, idx)
        end
      end
    end
  end

  # => def template_sidekiq(from, to, role)
  # =>   [
  # =>       File.join('lib', 'capistrano', 'templates', "#{from}-#{role.hostname}-#{fetch(:stage)}.rb"),
  # =>       File.join('lib', 'capistrano', 'templates', "#{from}-#{role.hostname}.rb"),
  # =>       File.join('lib', 'capistrano', 'templates', "#{from}-#{fetch(:stage)}.rb"),
  # =>       File.join('lib', 'capistrano', 'templates', "#{from}.rb.erb"),
  # =>       File.join('lib', 'capistrano', 'templates', "#{from}.rb"),
  # =>       File.join('lib', 'capistrano', 'templates', "#{from}.erb"),
  # =>       File.expand_path("../../templates/#{from}.rb.erb", __FILE__),
  # =>       File.expand_path("../../templates/#{from}.erb", __FILE__)
  # =>   ].each do |path|
  # =>     if File.file?(path)
  # =>       erb = File.read(path)
  # =>       upload! StringIO.new(ERB.new(erb).result(binding)), to
  # =>       break
  # =>     end
  # =>   end
  # => end

end
