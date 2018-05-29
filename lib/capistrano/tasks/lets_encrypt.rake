# require 'capistrano/magic_recipes/base_helpers'
# include Capistrano::MagicRecipes::BaseHelpers

namespace :load do
  task :defaults do
    set :lets_encrypt_roles,        -> { :web }
    set :lets_encrypt_path,         -> { "~" }
    set :lets_encrypt_domains,      -> { fetch(:nginx_major_domain,false) ? [fetch(:nginx_major_domain)] + Array(fetch(:nginx_domains)) : Array(fetch(:nginx_domains)) }
    set :lets_encrypt__www_domains, -> { true }
    set :lets_encrypt_renew_minute, -> { "23" }
    set :lets_encrypt_renew_hour1,  -> { "0" }
    set :lets_encrypt_renew_hour2,  -> { "12" }
    set :lets_encrypt_renew_hour,   -> { "#{ fetch(:lets_encrypt_renew_hour1) },#{ fetch(:lets_encrypt_renew_hour2) }" }
    set :lets_encrypt_cron_log,     -> { "#{shared_path}/log/lets_encrypt_cron.log" }
    set :lets_encrypt_email,        -> { "ssl@example.com" }
  end
end

namespace :lets_encrypt do
  
  desc "Install certbot LetsEncrypt"
  task :install do
    on release_roles fetch(:lets_encrypt_roles) do
      within fetch(:lets_encrypt_path) do
        execute "wget https://dl.eff.org/certbot-auto"
        execute "chmod a+x certbot-auto"
      end
    end
  end
  
  
  desc "Generate LetsEncrypt certificate"
  task :certonly do
    on release_roles fetch(:lets_encrypt_roles) do
      # execute "./certbot-auto certonly --webroot -w /var/www/example -d example.com -d www.example.com -w /var/www/thing -d thing.is -d m.thing.is"
      execute :sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto --non-interactive --agree-tos --email #{fetch(:lets_encrypt_email)} certonly --webroot -w #{current_path}/public #{ Array(fetch(:lets_encrypt_domains)).map{ |d| "-d #{d.gsub(/^\*?\./, "")}#{ fetch(:lets_encrypt__www_domains,false) ? " -d www.#{d.gsub(/^\*?\./, "")}" : "" }" }.join(" ") }"
    end
  end
  
  
  desc "Upload LetsEncrypt cron-job"
  ## http://serverfault.com/a/825032
  task :auto_renew do
    on release_roles fetch(:lets_encrypt_roles) do
      # execute :sudo, "echo '42 0,12 * * * root (#{ fetch(:lets_encrypt_path) }/certbot-auto renew --quiet) >> #{shared_path}/lets_encrypt_cron.log 2>&1' | cat > #{ fetch(:lets_encrypt_path) }/lets_encrypt_cronjob"
      execute :sudo, "echo '#{ fetch(:lets_encrypt_renew_minute) } #{ fetch(:lets_encrypt_renew_hour) } * * * root #{ fetch(:lets_encrypt_path) }/certbot-auto renew --no-self-upgrade --post-hook \"#{fetch(:nginx_service_path)} restart\"  >> #{ fetch(:lets_encrypt_cron_log) } 2>&1' | cat > #{ fetch(:lets_encrypt_path) }/lets_encrypt_cronjob"
      execute :sudo, "mv -f #{ fetch(:lets_encrypt_path) }/lets_encrypt_cronjob /etc/cron.d/lets_encrypt"
      execute :sudo, "chown -f root:root /etc/cron.d/lets_encrypt"
      execute :sudo, "chmod -f 0644 /etc/cron.d/lets_encrypt"
    end
  end
  
  
  desc "Dry-Run Renew LetsEncrypt"
  task :dry_renew do
    on release_roles fetch(:lets_encrypt_roles) do
      # execute :sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto renew --dry-run"
      output = capture(:sudo, "#{ fetch(:lets_encrypt_path) }/certbot-auto renew --dry-run")
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
      output.each_line do |line|
          puts line
      end
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
    end
  end
  
  
  desc "Generate Strong Diffie-Hellman Group"
  task :generate_dhparam do
    on release_roles fetch(:lets_encrypt_roles) do
      dh_path = fetch(:nginx_diffie_hellman_param).to_s.split("/")
      dh_path.pop
      execute :sudo, "mkdir -p #{ dh_path.join("/") }"
      execute :sudo, "openssl dhparam -out #{ fetch(:nginx_diffie_hellman_param) } 2048"
    end
  end
  
  
  desc "Check CRON logs in syslog"
  task :check_cron_logs do
    on release_roles fetch(:lets_encrypt_roles) do
      # execute "grep CRON /var/log/syslog"
      output = capture(:sudo, "grep CRON /var/log/syslog")
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
      output.each_line do |line|
          puts line
      end
      puts "#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#"
    end
  end
  
end



