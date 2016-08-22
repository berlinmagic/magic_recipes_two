require 'capistrano/magic_recipes/base_helpers'
include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    set :secrets_roles,       -> { :app }
    set :secrets_profile,     -> { "bashrc" } # "profile" | "bashrc"
    set :secrets_key_base,    -> { generate_secrect_key }
    set :secrets_key_name,    -> { "#{ fetch(:application) }_#{ fetch(:stage) }_SECRET_KEY_BASE".gsub(/-/, "_").gsub(/[^a-zA-Z_]/, "").upcase }
    set :secrets_user_path,   -> { "/home/#{fetch(:user)}" }
    set :secrets_set_both,    -> { false }
    set :secrets_hooks,       -> { true }
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
  
  
  desc "set secret-key in .profile or .bashrc"
  task :profile do
    on release_roles fetch(:secrets_roles) do
      within fetch(:secrets_user_path) do
        execute :sudo,  "echo 'export #{fetch(:secrets_key_name)}=#{fetch(:secrets_key_base)}' | cat >> .#{fetch(:secrets_profile)}"
        if fetch(:secrets_set_both, false)
          execute :sudo,  "echo 'export SECRET_KEY_BASE=#{fetch(:secrets_key_base)}' | cat >> .#{fetch(:secrets_profile)}"
        end
      end
    end
  end
  
  
  desc "export secret-key in actual bash env"
  task :export do
    on release_roles fetch(:secrets_roles) do
      within fetch(:secrets_user_path) do
        execute "export #{fetch(:secrets_key_name)}=#{fetch(:secrets_key_base)}"
        if fetch(:secrets_set_both, false)
          execute "export SECRET_KEY_BASE=#{fetch(:secrets_key_base)}"
        end
      end
    end
  end
  
  
  desc "export secret-key in actual bash env"
  task :printenv do
    on release_roles fetch(:secrets_roles) do
      within fetch(:secrets_user_path) do
        execute "printenv"
        execute :echo, "$SECRET_KEY_BASE"
        execute :echo, "$#{fetch(:secrets_key_name)}"
      end
    end
  end
  
  
  desc 'secrets setup task (upload and set)'
  task :setup do
    invoke "secrets:profile"
    invoke "secrets:export"
    invoke "secrets:upload"
  end
  
  
  task :secrets_yml_symlink do
    set :linked_files, fetch(:linked_files, []).push('config/secrets.yml')
  end

  after 'deploy:started', 'secrets:secrets_yml_symlink'
  
  
end




desc 'Server setup tasks'
task :setup do
  invoke "secrets:setup" if fetch(:secrets_hooks)
end
