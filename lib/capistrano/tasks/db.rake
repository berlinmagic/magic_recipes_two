namespace :load do
  task :defaults do
    set :db_roles, -> { :db }
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
  
end

