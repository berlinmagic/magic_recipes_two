namespace :load do
  task :defaults do
    set :db_roles,            -> { :db }
    set :db_backup_on_deploy, -> { false }
  end
end

namespace :db do
  
  
  desc "seed the database"
  task :seed do
    on release_roles fetch(:db_roles) do
      within current_path do
        execute :bundle, :exec, :rake, "db:seed RAILS_ENV=#{fetch(:stage)}"
      end
    end
  end
  
  desc 'Dumb database and download yaml file'
  task :yaml_dumb do
    # create local backup-dir if not existing
    run_locally do
      execute :mkdir, "-p db/backups" 
    end
    # download yaml version of current DB
    on roles :db do
      within current_path do
        execute :bundle, :exec, :rake, "db:data:dump RAILS_ENV=#{fetch(:stage)}"
        # => download! "#{current_path}/db/data.yml", "db/backups/#{ Time.now.strftime("%y-%m-%d_%H-%M") }_#{fetch(:stage)}_db_data.yml"
        execute "cd #{current_path}/db ; tar -czvf data-dumb.tar.gz data.yml"
        download! "#{current_path}/db/data-dumb.tar.gz", "db/backups/#{ Time.now.strftime("%y-%m-%d_%H-%M") }_#{fetch(:stage)}_db_data.tar.gz"
      end
    end
  end
  
end

namespace :deploy do
  before :starting, :backup_database do
    if fetch(:db_backup_on_deploy)
      invoke "db:yaml_dumb"
    end
  end
end