# MagicRecipesTwo

Our most used recipes for Capistrano-3!

Not using capistrano-3, see [Capistrano 2 version](https://github.com/twetzel/magic_recipes)


### Includes

- **assets** compile assets locally, than upload them (fully integrated)
- **db** seed task + backup task
- **exception_pages** copy exception pages from assets to public (if you generate them with sprockets)
- **inform_slack** inform a slack channel about successful upload
- **monit** control monit with monit-webinterface
- **monit_sidekiq** monit tasks for sidekiq (unused!!)
- **nginx** control nginx with several instances and ssl
- **redis** control redis
- **secrets** handling of rails 4 secrets
- **sidekiq** control sidekiq
- **thin** control thin


### NEWs


**Version 0.0.40:**
- new `:db_backup_on_deploy` .. make DB backup before deployment
 
 

**Version 0.0.35:**
- new `:monit_sidekiq_totalmem_mb` .. sets maximum mb of ram for sidekiq
- new `:monit_sidekiq_timeout_sec` .. sets timeout for sidekiq when sarted/stoped via monit
 
 

**Version 0.0.33:**
- new `:monit_sidekiq_with_secret` if true, sets *secret_key_base* when starting **sidekiq** via monit
 
 

**Version 0.0.32:**
- monit now has a status *(active|inactive)* !!
- **monit needs `:monit_active` to be true, otherwise won't work**
- **monit needs `:monit_processes` to include all processes you want to monitor**
- nginx hooks in deploy chain, `:nginx_hooks` to control
- thin hooks in deploy chain, `:thin_hooks` to control
- secrets hooks in setup chain, `:secrets_hooks` to control
 
 

**Version 0.0.31:**
- **contains monit Bug!!**
 
 

**Version 0.0.30:**
- new `:monit_thin_with_secret` if true, sets *secret_key_base* when starting **thin** via monit

*needs the secrets-tasks and `:secrets_key_base` + `:secrets_key_name` to work*
 
 

**Version 0.0.18:**
- optional NginX Proxy-Cash for Rails and/or an optional path for Dragonfly/Paperclip
 
 

### ToDos

- clean up code
- write some generators
- testing

---
#### Still work on progress .. so maybe not full production ready! .. but also used in production :)
---

## Usage

- add Gem to your gemfile
```ruby
  gem 'magic_recipes_two', '>= 0.0.40', group: :development
```
- run `bundle`
- run `bundle exec cap install`
- add the following:


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


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => bundler
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :bundle_roles,         :all                                  # this is default
# => set :bundle_servers,       release_roles(fetch(:bundle_roles)) } # this is default
# => set :bundle_binstubs,      shared_path.join('bin') }             # default: nil
# => set :bundle_gemfile,       release_path.join('MyGemfile') }      # default: nil
# => set :bundle_path,          shared_path.join('my_special_bundle') # default: nil
# => set :bundle_without,       %w{development test}.join(' ')        # this is default
# => set :bundle_flags,         '--deployment --quiet'                # this is default
# => set :bundle_env_variables, {}                                    # this is default
# => set :bundle_bins, fetch(:bundle_bins, []).push('my_new_binary')  # You can add any custom executable to this list


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => db
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :db_roles,             :db
# => set :db_backup_on_deploy,  false   # make DB backup (yaml_db) before deployment


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => inform slack
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :slack_token,           "xxx-xxx-xxx-xxx"
# => set :slack_channel,         "xxx-xxx-xxx-xxx" # "channel_id" or "#channel_name"
# => set :slack_text,            "New Deployment on *#{ fetch(:stage) }* ... check:  #{fetch(:nginx_use_ssl) ? 'https': 'htpp'}://#{ fetch(:nginx_major_domain) ? fetch(:nginx_major_domain).gsub(/^\*?\./, "") : Array( fetch(:nginx_domains) ).first.gsub(/^\*?\./, "") }"
# => set :slack_username,        "capistrano (#{fetch(:stage)})"
# => set :slack_production_icon, "http://icons.iconarchive.com/icons/itzikgur/my-seven/128/Backup-IBM-Server-icon.png"
# => set :slack_staging_icon,    "http://itekblog.com/wp-content/uploads/2012/07/railslogo.png"


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => monit
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## Status (monit is running or not .. activate monit hooks in deploy chain)
# => set :monit_active,                         true
## Monit-Processes (what should be monitored) = nginx postgresql redis sidekiq thin
# => set :monit_processes,                      %w[nginx postgresql thin]
## Monit System
# => set :monit_roles,                          :web
# => set :monit_interval,                       30
# => set :monit_bin,                            '/usr/bin/monit'
## Monit Log-File (Monit default: '/var/log/monit.log')
# => set :monit_logfile,                        "#{shared_path}/log/monit.log"
# => set :monit_idfile,                         '/var/lib/monit/id'
# => set :monit_statefile,                      '/var/lib/monit/state'
## Mailer
# => set :monit_mail_server,                    "smtp.gmail.com"
# => set :monit_mail_port,                      587
# => set :monit_mail_authentication,            false # SSLAUTO|SSLV2|SSLV3|TLSV1|TLSV11|TLSV12
# => set :monit_mail_username,                  "foo@example.com"
# => set :monit_mail_password,                  "secret"
## Change me!!
# => set :monit_mail_to,                        "foo@example.com"
# => set :monit_mail_from,                      "monit@foo.bar"
# => set :monit_mail_reply_to,                  "support@foo.bar"
## Additional stuff for postrgres
# => set :postgresql_roles,                     :db
# => set :postgresql_pid,                       "/var/run/postgresql/9.1-main.pid"
## Additional stuff for thin (need secrets_key_base to be set)
# => set :monit_thin_with_secret,               false
# => set :monit_thin_totalmem_mb,               300
## Additional stuff for sidekiq (need secrets_key_base to be set)
# => set :monit_sidekiq_with_secret,            false
# => set :monit_sidekiq_totalmem_mb,            300
# => set :monit_sidekiq_timeout_sec,            90
## WebClient
# => set :monit_http_client,                    true
# => set :monit_http_domain,                    false
# => set :monit_http_port,                      2812
# => set :monit_http_use_ssl,                   false
# => set :monit_http_allow_self_certification,  false
# => set :monit_http_pemfile,                   "/etc/monit/monit.pem"
# => set :monit_http_username,                  "admin"
# => set :monit_http_password,                  "monitor"


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => nginx
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## all domains the app uses
# => set :nginx_domains,                   []               # array of domains
## app is the default site for this server?
# => set :default_site,                    false            # true | false
## all domains are redirected to this one, domain
# => set :nginx_major_domain,              false            # "domain-name.tld" | false
## remove "www" from each request?
# => set :nginx_remove_www,                true             # true | false
## remove "https" from each request?
# => set :nginx_remove_https,              false             # true | false
## how many (thin) server instances 
# => set :app_instances,                   1                # number >= 1
## nginx service path
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
## activate nginx hooks in deploy chain ?
# => set :nginx_hooks,                     true
## ## ##
## NginX Proxy-Cache
## ## ##
# -> Send appropriate cache headers ( Cache-Control: max-age=X, public ) to activate cache
# -> Send bypass headers ( bypass_proxy: true ) to bypass cache
## ## ##
## Cache Rails-App
## ## ##
# => set :proxy_cache_rails,           false                                                   # cache active?
# => set :proxy_cache_rails_directory, "#{shared_path}/tmp/proxy_cache/rails"                  # cache directory
# => set :proxy_cache_rails_levels,    "1:2"                                                   # cache level
# => set :proxy_cache_rails_name,      "RAILS_#{fetch(:application)}_#{fetch(:stage)}_CACHE"   # cache name
# => set :proxy_cache_rails_size,      "4m"                                                    # max-key-size ( 1m = 8000 keys)
# => set :proxy_cache_rails_time,      "24h"                                                   # cache invalidate after
# => set :proxy_cache_rails_max,       "1g"                                                    # max-cache-size
# cache 200 / 302 Pages ?
# => set :proxy_cache_rails_200,       false                                                   # false | time
# cache 404 Pages ?
# => set :proxy_cache_rails_404,       "60m"                                                   # false | time
# use stale content when state is in:
# => set :proxy_cache_rails_stale,     ["error", "timeout", "invalid_header", "updating"]      # stale when (array)
## ## ##
## Cache Media (Dragonfly/Paperclip/..) 
## ## ##
# => set :proxy_cache_media,           false                                                   # cache active?
# media-path ('media' for dargonfly, 'system' for paperclip)
# => set :proxy_cache_media_path,      "media"                                                 # media path (string)
# => set :proxy_cache_media_directory, "#{shared_path}/tmp/proxy_cache/media"                  # cache directory
# => set :proxy_cache_media_levels,    "1:2"                                                   # cache level
# => set :proxy_cache_media_name,      "MEDIA_#{fetch(:application)}_#{fetch(:stage)}_CACHE"   # cache name
# => set :proxy_cache_media_size,      "2m"                                                    # max-key-size ( 1m = 8000 keys)
# => set :proxy_cache_media_time,      "48h"                                                   # cache invalidate after
# => set :proxy_cache_media_max,       "1g"                                                    # max-cache-size


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => postgresql
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :pg_database,         "#{fetch(:application)}_#{fetch(:stage)}"
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


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => rails
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :rails_env, 'staging'                  # If the environment differs from the stage name
# => set :migration_role, 'migrator'            # Defaults to 'db'
# => set :conditionally_migrate, true           # Defaults to false. If true, it's skip migration if files in db/migrate not modified
# => set :assets_roles, [:web, :app]            # Defaults to [:web]
# => set :assets_prefix, 'prepackaged-assets'   # Defaults to 'assets' this should match config.assets.prefix in your rails config/application.rb
## If you need to touch public/images, public/javascripts and public/stylesheets on each deploy:
# => set :normalize_asset_timestamps, %{public/images public/javascripts public/stylesheets}


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => redis
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :redis_roles,   :web
# => set :redis_pid,     "/var/run/redis/redis-server.pid"


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => rvm1 capistrano3
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :rvm1_ruby_version,     "."
# => set :rvm1_map_bins,         %w{rake gem bundle ruby}
# => set :rvm1_alias_name,       fetch(:application)
# => set :rvm1_auto_script_path, "#{fetch(:deploy_to)}/rvm1scripts"


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => secrets
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :secrets_roles,       :app
# => set :secrets_profile,     "bashrc" # "profile" | "bashrc"
# => set :secrets_key_base,    generate_secrect_key
# => set :secrets_key_name,    "#{ fetch(:application) }_#{ fetch(:stage) }_SECRET_KEY_BASE".gsub(/-/, "_").gsub(/[^a-zA-Z_]/, "").upcase
# => set :secrets_user_path,   { "/home/#{fetch(:user)}"
# => set :secrets_set_both,    false  # also save usual SECRET_KEY_BASE 
# => set :secrets_hooks,       true   # activate thin hooks in setup chain ?


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => sidekiq
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :sidekiq_default_hooks,   true
# => set :sidekiq_pid,             File.join(shared_path, 'pids', 'sidekiq.pid')
# => set :sidekiq_env,             fetch(:rack_env, fetch(:rails_env, fetch(:stage)))
# => set :sidekiq_log,             File.join(shared_path, 'log', 'sidekiq.log')
# => set :sidekiq_timeout,         10
# => set :sidekiq_roles,           :app
# => set :sidekiq_processes,       1
## Rbenv and RVM integration
# => set :rbenv_map_bins,          fetch(:rbenv_map_bins).to_a.concat(%w(sidekiq sidekiqctl))
# => set :rvm_map_bins,            fetch(:rvm_map_bins).to_a.concat(%w(sidekiq sidekiqctl))


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => thin
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
# => set :thin_path,                  '/etc/thin'     # => thin path on your server
# => set :thin_roles,                 :web            # => thin roles
# => set :thin_timeout,               30              # => Request or command timeout in sec (default: 30)
# => set :thin_max_conns,             1024            # => Maximum number of open file descriptors (default: 1024)
# => set :thin_max_persistent_conns,  512             # => Maximum number of persistent connections (default: 100)
# => set :thin_require,               []              # => require the library
# => set :thin_wait,                  90              # => Maximum wait time for server to be started in seconds
# => set :thin_onebyone,              true            # => for zero-downtime deployment (only works with restart command)
# => set :thin_hooks,                 true            # => activate thin hooks in deploy chain ?


## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
```


---

This project rocks and uses MIT-LICENSE.