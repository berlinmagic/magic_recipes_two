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
        download! "#{current_path}/db/data-dumb.tar.gz", "db/backups/#{ Time.now.strftime("%y-%m-%d_%H-%M") }_#{fetch(:stage)}_db.tar.gz"
      end
    end
  end
  
  
  desc "upload data.yml to server and load it = DELETES EXISTING DATA"
  task :upload_and_replace_data do
    on roles fetch(:db_roles) do
      puts()
      puts()
      puts("   ! ! !     C A U T I O N !     ! ! ! ")
      puts()
      puts()
      puts("This will upload 'local-App/db/data.yml' and load it in current DB")
      puts()
      puts("This will   DELETE ALL DATA   in your #{ fetch(:stage) } DB!!")
      puts()
      ask(:are_you_sure, 'no')
      if fetch(:are_you_sure, 'no').to_s.downcase == 'yes'
        local_dir = "./db/data.yml"
        remote_dir = "#{host.user}@#{host.hostname}:#{release_path}/db/data.yml"
        puts(".. uploading db/data.yml")
        run_locally { execute "rsync -av --delete #{local_dir} #{remote_dir}" }
        puts(".. loading data.yml in #{ fetch(:stage) } DB")
        within release_path do
          execute :bundle, :exec, :rake, "db:data:load RAILS_ENV=#{fetch(:stage)}"
        end
      else
        puts(".. stoped process ..")
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