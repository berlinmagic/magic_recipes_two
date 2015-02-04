namespace :load do
  task :defaults do
    set :secrets_roles, -> { :app }
  end
end

namespace :secrets do
  
  
  desc "upload secrets yaml"
  task :upload do
    on release_roles fetch(:secrets_roles) do
      within shared_path do
        upload! File.expand_path("../../../../config/secrets.yml", __FILE__), '/tmp/secrets.yml'
        
        execute :sudo, :mv, '/tmp/secrets.yml', "config/secrets.yml"
      end
    end
  end
  
  
end