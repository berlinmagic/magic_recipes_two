# Clear existing task so we can replace it rather than "add" to it.
Rake::Task["deploy:compile_assets"].clear 

namespace :deploy do
  
  desc 'Compile assets'
  task :compile_assets => [:set_rails_env] do
    # invoke 'deploy:assets:precompile'
    invoke 'deploy:assets:precompile_local'
    invoke 'deploy:assets:backup_manifest'
  end
  
  
  namespace :assets do
    
    desc "Precompile assets locally and then rsync to web servers" 
    task :precompile_local do 
      # compile assets locally
      # run_locally do
      #   with rails_env: fetch(:stage) do
      #     execute :bundle, "exec rake assets:precompile"
      #   end
      # end
      run_locally do
        execute "RAILS_ENV=#{fetch(:stage)} bundle exec rake assets:precompile"
      end

      # rsync to each server
      local_dir = "./public/assets/"
      on roles( fetch(:assets_roles, [:web]) ) do
        # this needs to be done outside run_locally in order for host to exist
        remote_dir = "#{host.user}@#{host.hostname}:#{release_path}/public/assets/"
    
        run_locally { execute "rsync -av --delete #{local_dir} #{remote_dir}" }
        
        execute :sudo, :chmod, "-R 777 #{release_path}/public"
      end

      # clean up
      run_locally { execute "rm -rf #{local_dir}" }
    end
    
  end
  
end