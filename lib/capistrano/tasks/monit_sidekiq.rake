# https://github.com/seuros/capistrano-sidekiq
namespace :load do
  task :defaults do
    set :sidekiq_monit_conf_dir, -> { '/etc/monit/conf.d' }
    set :monit_bin, -> { '/usr/bin/monit' }
  end
end


namespace :sidekiq do
  namespace :monit do
    desc 'Config Sidekiq monit-service'
    task :config do
      on roles(fetch(:sidekiq_roles)) do |role|
        @role = role
        template_with_role 'sidekiq', "#{fetch(:tmp_dir)}/monit.conf", @role
        sudo "mv #{fetch(:tmp_dir)}/monit.conf #{fetch(:sidekiq_monit_conf_dir)}/#{sidekiq_service_name}.conf"
      end
    end


    ## Server specific tasks (gets overwritten by other environments!)
    %w[monitor unmonitor start stop restart].each do |command|
      desc "#{command} Sidekiq monit-service"
      task command do
        on roles(fetch(:sidekiq_roles)) do
          fetch(:sidekiq_processes).times do |idx|
            sudo "#{fetch(:monit_bin)} #{command} #{sidekiq_service_name(idx)}"
          end
        end
      end
    end


    def sidekiq_service_name(index=nil)
      fetch(:sidekiq_service_name, "#{fetch(:application)}_#{fetch(:stage)}_sidekiq_") + index.to_s
    end

  end
end