# require 'capistrano/magic_recipes/base_helpers'
# include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    set :lets_encrypt_roles,    -> { :web }
    set :lets_encrypt_path,     -> { "~" }
  end
end

namespace :lets_encrypt do
  
  desc "Install certbot LetsEncrypt"
  task :install do
    on release_roles fetch(:lets_encrypt_roles) do
      execute "cd #{ fetch(:lets_encrypt_path) } ; wget https://dl.eff.org/certbot-auto"
      execute "cd #{ fetch(:lets_encrypt_path) } ; chmod a+x certbot-auto"
    end
  end
  
  
  desc "Install certbot LetsEncrypt"
  task :certonly do
    on release_roles fetch(:lets_encrypt_roles) do
      # execute "./certbot-auto certonly --webroot -w /var/www/example -d example.com -d www.example.com -w /var/www/thing -d thing.is -d m.thing.is"
      execute :sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto certonly --webroot -w #{current_path}/public#{ fetch(:nginx_major_domain, false) ? " -d #{fetch(:nginx_major_domain).to_s.gsub(/^\*?\./, "")} -d www.#{fetch(:nginx_major_domain).to_s.gsub(/^\*?\./, "")}" : ""} #{ Array(fetch(:nginx_domains)).map{ |d| "-d #{d.gsub(/^\*?\./, "")} -d www.#{d.gsub(/^\*?\./, "")}" }.join(" ") }"
    end
  end
  
  
  desc "Install certbot LetsEncrypt"
  ## http://serverfault.com/a/825032
  task :auto_renew do
    on release_roles fetch(:lets_encrypt_roles) do
      execute :sudo, "echo '42 0,12 * * * root #{ fetch(:lets_encrypt_path) }/certbot-auto renew --quiet' | cat > /etc/cron.d/lets_encrypt"
    end
  end
  
  
  desc "Install certbot LetsEncrypt"
  task :test_renew do
    on release_roles fetch(:lets_encrypt_roles) do
      execute :sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto renew --dry-run"
    end
  end
  
  
  desc "Generate Strong Diffie-Hellman Group"
  task :generate_dhparam do
    on release_roles fetch(:lets_encrypt_roles) do
      execute :sudo, "openssl dhparam -out #{ fetch(:nginx_ssl_dh_path) }/#{ fetch(:nginx_ssl_dh_file) } 2048"
    end
  end
  
  
end



