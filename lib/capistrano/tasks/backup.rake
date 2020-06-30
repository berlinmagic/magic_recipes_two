require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers


namespace :load do
  task :defaults do
    
    set :backup_attachment_roles,       -> { :app, :web }
    set :backup_attachment_name,        -> { 'dragonfly' }
    set :backup_attachment_remote_path, -> { "#{host.user}@#{host.hostname}:#{shared_path}/public/system/dragonfly/live" }
    set :backup_attachment_local_path,  -> { "backups/#{ fetch(:backup_attachment_name) }/#{ fetch(:stage) }" }
    
  end
end



namespace :backup do

  desc "download attachment files from server"
  task :get_attachments do
    on roles fetch(:backup_attachment_roles) do
      run_locally do
        execute :mkdir, "-p #{fetch(:backup_attachment_local_path)}"
      end
      run_locally { execute "rsync -av --delete #{ fetch(:backup_attachment_remote_path) }/ #{ fetch(:backup_attachment_local_path) }" }
    end
  end

  desc "upload attachment files from local machine"
  task :push_attachment do
    on roles fetch(:backup_attachment_roles) do
      run_locally { execute "rsync -av --delete #{ fetch(:backup_attachment_local_path) }/ #{ fetch(:backup_attachment_remote_path) }" }
    end
  end


end