require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    set :secrets_roles,       -> { :app }
    set :secrets_profile,     -> { "profile" } # "profile" | "bashrc"
    set :secrets_key_base,    -> { generate_secrect_key }
    set :secrets_token,       -> { generate_secrect_key }
    set :secrets_key_name,    -> { "#{ fetch(:application) }_#{ fetch(:stage) }_SECRET_KEY_BASE".gsub(/-/, "_").gsub(/[^a-zA-Z_]/, "").upcase }
    set :secrets_token_name,  -> { "#{ fetch(:application) }_#{ fetch(:stage) }_SECRET_TOKEN".gsub(/-/, "_").gsub(/[^a-zA-Z_]/, "").upcase }
    set :secrets_user_path,   -> { "/home/#{fetch(:user)}" }
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
        execute :sudo,  "echo 'export #{fetch(:secrets_key_name)}=#{fetch(:secrets_key_base)}' | cat >> .#{fetch(:secrets_profile)}"
        execute :sudo,  "echo 'export #{fetch(:secrets_token_name)}=#{fetch(:secrets_token)}' | cat >> .#{fetch(:secrets_profile)}"
        execute "export #{fetch(:secrets_key_name)}=#{fetch(:secrets_key_base)}"
        execute "export #{fetch(:secrets_token_name)}=#{fetch(:secrets_token)}"
      end
    end
  end
  
  desc 'secrets setup task (upload and set)'
  task :setup do
    invoke "secrets:export"
    invoke "secrets:upload"
  end
  
  
  task :secrets_yml_symlink do
    set :linked_files, fetch(:linked_files, []).push('config/secrets.yml')
  end

  after 'deploy:started', 'secrets:secrets_yml_symlink'
  
  
end