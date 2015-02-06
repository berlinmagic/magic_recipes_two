require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    set :secrets_roles,     -> { :app }
    set :secrets_key_base,  -> { generate_secrect_key }
    set :secrets_key_name,  -> { "#{ fetch(:application) }_#{ fetch(:stage) }_SECRET_KEY_BASE".gsub(/-/, "_").gsub(/[^a-zA-Z_]/, "").upcase }
    set :secrets_user_path, -> { "/home/#{fetch(:user)}" }
  end
end

namespace :secrets do
  
  
  desc "upload secrets yaml"
  task :upload do
    on release_roles fetch(:secrets_roles) do
      within shared_path do
        magic_template("secrets_yml", '/tmp/secrets.yml')
        execute :sudo, :mv, '/tmp/secrets.yml', "config/secrets.yml"
      end
    end
  end
  
  
  desc "set secret-key in .bashrc"
  task :export do
    on release_roles fetch(:secrets_roles) do
      within fetch(:secrets_user_path) do
        execute :sudo,  "echo 'export #{fetch(:secrets_key_name)}=#{fetch(:secrets_key_base)}' | cat >> .bashrc"
        execute "export #{fetch(:secrets_key_name)}=#{fetch(:secrets_key_base)}"
      end
    end
  end
  
  desc 'secrets setup task (upload and set)'
  task :setup do
    invoke "secrets:export"
    invoke "secrets:upload"
  end
  
end