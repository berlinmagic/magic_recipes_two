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
    
  end
end


namespace :thin do
  
  
  desc "rewrite thin-configurations"
  task :reconf => ['nginx:load_vars'] do
    on release_roles fetch(:thin_roles) do
      within current_path do
        magic_template("thin_app_yml", '/tmp/thin_app.yml')
        execute :sudo, :mv, '/tmp/thin_app.yml', "config/thin_app_#{fetch(:stage)}.yml"
        execute :sudo, :rm, ' -f', "#{fetch(:thin_path)}/thin_#{fetch(:application)}_#{fetch(:stage)}*"
        execute :sudo, :ln, ' -sf', "#{current_path}/config/thin_app_#{fetch(:stage)}.yml", "#{fetch(:thin_path)}/thin_#{fetch(:application)}_#{fetch(:stage)}.yml"
      end
    end
  end
  
  
  %w[start stop restart].each do |command|
    desc "#{command} thin"
    task command => ['nginx:load_vars'] do
      on release_roles fetch(:thin_roles) do
        within current_path do
          execute :bundle, :exec, :thin, "#{command} -C config/thin_app_#{fetch(:stage)}.yml"
        end
      end
    end
  end
  
  
end

after 'deploy:published', nil do
  on release_roles fetch(:thin_roles) do
    invoke "thin:reconf"
    invoke "thin:restart"
  end
end
