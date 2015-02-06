# MagicRecipesTwo

Our most used recipes for Capistrano-3!

Not using capistrano-3, see [Capistrano 2 version](https://github.com/twetzel/magic_recipes)


### Includes

- **assets** compile assets locally, than upload them (fully integrated)
- **db** seed task
- **exception_pages** copy exception pages from assets to public (if you generate them with sprockets)
- **inform_slack** inform a slack channel about successful upload
- **monit** control monit and monit-webinterface
- **monit_sidekiq** monit tasks for sidekiq (unused!!)
- **nginx** control nginx with several instances and ssl
- **redis** control redis
- **secrets** handling of rails 4 secrets
- **sidekiq** control sidekiq
- **thin** control thin


### ToDos

- clean up code
- write some generators
- testing

---
#### Still work on progress .. so absolutely not production ready!
---


## in Capfile

```ruby
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
## MagicRecipes .. pick what you need

# => require 'rvm1/capistrano3'
# => require 'capistrano/bundler'
# => require 'capistrano/rails/assets'
# => require 'capistrano/rails/migrations'
# => require 'capistrano/postgresql'

# => require 'capistrano/magic_recipes/assets'
# => require 'capistrano/magic_recipes/db'
# => require 'capistrano/magic_recipes/exception_pages'
# => require 'capistrano/magic_recipes/inform_slack'
# => require 'capistrano/magic_recipes/monit'
# => require 'capistrano/magic_recipes/nginx'
# => require 'capistrano/magic_recipes/redis'
# => require 'capistrano/magic_recipes/secrets'
# => require 'capistrano/magic_recipes/sidekiq'
# => require 'capistrano/magic_recipes/thin'

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
```


## in deploy file

```ruby
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
## MagicRecipes .. pick what you need
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 

# => set :user,        'deployuser'
# => set :deploy_to,   "/home/#{fetch(:user)}/#{fetch(:application)}-#{fetch(:stage)}"


## bundler
  # => set :bundle_roles,         :all                                  # this is default
  # => set :bundle_servers,       release_roles(fetch(:bundle_roles)) } # this is default
  # => set :bundle_binstubs,      shared_path.join('bin') }             # default: nil
  # => set :bundle_gemfile,       release_path.join('MyGemfile') }      # default: nil
  # => set :bundle_path,          shared_path.join('my_special_bundle') # default: nil
  # => set :bundle_without,       %w{development test}.join(' ')        # this is default
  # => set :bundle_flags,         '--deployment --quiet'                # this is default
  # => set :bundle_env_variables, {}                                    # this is default
  # => set :bundle_bins, fetch(:bundle_bins, []).push('my_new_binary')  # You can add any custom executable to this list


## db
  # => set :db_roles, :db


## inform slack
  # => set :slack_token,           "xxx-xxx-xxx-xxx"
  # => set :slack_channel,         "xxx-xxx-xxx-xxx"
  # => set :slack_text,            "New Deployment on *#{ fetch(:stage) }* ... check:  #{fetch(:nginx_use_ssl) ? 'https': 'htpp'}://#{ fetch(:nginx_major_domain) ? fetch(:nginx_major_domain).gsub(/^\*?\./, "") : Array( fetch(:nginx_domains) ).first.gsub(/^\*?\./, "") }"
  # => set :slack_username,        "capistrano (#{fetch(:stage)})"
  # => set :slack_production_icon, "http://icons.iconarchive.com/icons/itzikgur/my-seven/128/Backup-IBM-Server-icon.png"
  # => set :slack_staging_icon,    "http://itekblog.com/wp-content/uploads/2012/07/railslogo.png"


## monit
  # => set :monit_roles,               :web
  # => set :monit_interval,            30
  ## Mailer
  # => set :monit_mail_server,         "smtp.gmail.com"
  # => set :monit_mail_port,           587
  # => set :monit_mail_authentication, false # SSLAUTO|SSLV2|SSLV3|TLSV1|TLSV11|TLSV12
  # => set :monit_mail_username,       "foo@example.com"
  # => set :monit_mail_password,       "secret"
  # => set :monit_mail_to,             "foo@example.com"
  # => set :monit_mail_from,           "monit@foo.bar"
  # => set :monit_mail_reply_to,       "support@foo.bar"
  ## Additional stuff for postrgres
  # => set :postgresql_roles,          :db
  # => set :postgresql_pid,            "/var/run/postgresql/9.1-main.pid"
  ## WebClient
  # => set :monit_http_client,         true
  # => set :monit_http_domain,         false
  # => set :monit_http_port,           2812
  # => set :monit_http_use_ssl,        false
  # => set :monit_http_pemfile,        "/etc/monit/monit.pem"
  # => set :monit_http_username,       "admin"
  # => set :monit_http_password,       "monitor"


## nginx
  # => set :nginx_domains,                   []
  # => set :default_site,                    false
  # => set :app_instances,                   1
  # => set :nginx_service_path,              'service nginx'
  # => set :nginx_roles,                     :web
  # => set :nginx_log_path,                  "#{shared_path}/log"
  # => set :nginx_root_path,                 "/etc/nginx"
  # => set :nginx_static_dir,                "public"
  # => set :nginx_sites_enabled,             "sites-enabled"
  # => set :nginx_sites_available,           "sites-available"
  # => set :nginx_template,                  :default
  # => set :nginx_use_ssl,                   false
  # => set :nginx_ssl_certificate,           "#{fetch(:application)}.crt"
  # => set :nginx_ssl_certificate_path,      '/etc/ssl/certs'
  # => set :nginx_ssl_certificate_key,       "#{fetch(:application)}.crt"
  # => set :nginx_ssl_certificate_key_path,  '/etc/ssl/private'
  # => set :app_server_ip,                   "127.0.0.1"


## postgres
  # => set :pg_database,           "#{fetch(:application)}_#{fetch(:stage)}" }
  # => set :pg_user,             fetch(:pg_database)
  # => set :pg_ask_for_password, false
  # => set :pg_password,         ask_for_or_generate_password
  # => set :pg_system_user,      'postgres'
  # => set :pg_system_db,        'postgres'
  # => set :pg_use_hstore,       false
  # => set :pg_extensions,       []
  ## template only settings
  # => set :pg_templates_path,   'config/deploy/templates'
  # => set :pg_env,              fetch(:rails_env) || fetch(:stage)
  # => set :pg_pool,             5
  # => set :pg_encoding,         'unicode'
  ## for multiple release nodes automatically use server hostname (IP?) in the database.yml
  # => set :pg_host, -> do
  # =>   if release_roles(:all).count == 1 && release_roles(:all).first == primary(:db)
  # =>     'localhost'
  # =>   else
  # =>     primary(:db).hostname
  # =>   end
  # => end


## rails
  # => set :rails_env, 'staging'                  # If the environment differs from the stage name
  # => set :migration_role, 'migrator'            # Defaults to 'db'
  # => set :conditionally_migrate, true           # Defaults to false. If true, it's skip migration if files in db/migrate not modified
  # => set :assets_roles, [:web, :app]            # Defaults to [:web]
  # => set :assets_prefix, 'prepackaged-assets'   # Defaults to 'assets' this should match config.assets.prefix in your rails config/application.rb
  ## If you need to touch public/images, public/javascripts and public/stylesheets on each deploy:
  # => set :normalize_asset_timestamps, %{public/images public/javascripts public/stylesheets}


## redis
  # => set :redis_roles,   :web
  # => set :redis_pid,     "/var/run/redis/redis-server.pid"


## rvm1 capistrano3
  # => set :rvm1_ruby_version,     "."
  # => set :rvm1_map_bins,         %w{rake gem bundle ruby}
  # => set :rvm1_alias_name,       fetch(:application)
  # => set :rvm1_auto_script_path, "#{fetch(:deploy_to)}/rvm1scripts"


## secrets
  # => set :secrets_roles,       :app
  # => set :secrets_profile,     "profile" # "profile" | "bashrc"
  # => set :secrets_key_base,    generate_secrect_key
  # => set :secrets_key_name,    "#{ fetch(:application) }_#{ fetch(:stage) }_SECRET_KEY_BASE".gsub(/-/, "_").gsub(/[^a-zA-Z_]/, "").upcase
  # => set :secrets_user_path,   { "/home/#{fetch(:user)}"
  # => set :secrets_set_both,    false  # also save usual SECRET_KEY_BASE 


## sidekiq
  # => set :sidekiq_default_hooks,   true
  # => set :sidekiq_pid,             File.join(shared_path, 'tmp', 'pids', 'sidekiq.pid')
  # => set :sidekiq_env,             fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
  # => set :sidekiq_log,             File.join(shared_path, 'log', 'sidekiq.log')
  # => set :sidekiq_timeout,         10
  # => set :sidekiq_roles,           :app
  # => set :sidekiq_processes,       1
  ## Rbenv and RVM integration
  # => set :rbenv_map_bins,          fetch(:rbenv_map_bins).to_a.concat(%w(sidekiq sidekiqctl))
  # => set :rvm_map_bins,            fetch(:rvm_map_bins).to_a.concat(%w(sidekiq sidekiqctl))


## thin
  # => set :thin_path,     '/etc/thin'
  # => set :thin_roles,    :web

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
```


---

This project rocks and uses MIT-LICENSE.