# MagicRecipesTwo

Our most used recipes for Capistrano-3!

Not using capistrano-3, see [Capistrano 2 version](https://github.com/twetzel/magic_recipes)


### Includes

- **assets** compile assets locally, than upload them (fully integrated)
- **db** seed task + backup task
- **exception_pages** copy exception pages from assets to public (if you generate them with sprockets)
- **inform_slack** inform a slack channel about successful upload
- **lets encrypt** install certs, add cron job, create Diffie-Hellman
- **monit** control monit with monit-webinterface
- **monit_sidekiq** monit tasks for sidekiq (unused!!)
- **nginx** control nginx with several instances and ssl
- **redirect_page** a page that redirects to new domain after 10 sec. info old-page -> new-page
- **redis** control redis
- **secrets** handling of rails 4 secrets
- **sidekiq** control sidekiq
- **thin** control thin


### ChangeLog:

- [see gem CHANGELOG](https://github.com/berlinmagic/magic_recipes_two/blob/master/CHANGELOG.md)


---
#### Still work in progress .. so maybe not  ready for your needs! .. but also used a lot in production :)
---

## Usage

- add Gem to your gemfile
```ruby
  gem 'magic_recipes_two', '>= 0.0.81', group: :development
```
- run `bundle`
- run `bundle exec cap install`
- add the following:


## in Capfile

```ruby
    ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
    ## MagicRecipes .. pick what you need
    
    # => require 'capistrano/rvm'
    # => require 'rvm1/capistrano3'
    # => require 'capistrano/bundler'
    # => require 'capistrano/rails/assets'
    # => require 'capistrano/rails/migrations'
    # => require 'capistrano/postgresql'
    
    # => require 'capistrano/magic_recipes/assets'
    # => require 'capistrano/magic_recipes/db'
    # => require 'capistrano/magic_recipes/exception_pages'
    # => require 'capistrano/magic_recipes/inform_slack'
    # => require 'capistrano/magic_recipes/lets_encrypt'
    # => require 'capistrano/magic_recipes/logs'
    # => require 'capistrano/magic_recipes/monit'
    # => require 'capistrano/magic_recipes/nginx'
    # => require 'capistrano/magic_recipes/pwa'
    # => require 'capistrano/magic_recipes/redis'
    # => require 'capistrano/magic_recipes/redirect_page'
    # => require 'capistrano/magic_recipes/secrets'
    # => require 'capistrano/magic_recipes/sidekiq'
	# => require 'capistrano/magic_recipes/sidekiq_six'
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
## => lets encrypt  .. needs *nginx* :allow_well_known to be true!
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :lets_encrypt_roles,         :web
    # => set :lets_encrypt_path,          "~"
    # Array without www.domains "www" will be auto-added! .. First domain is main one!
    # => set :lets_encrypt_domains,       fetch(:nginx_major_domain,false) ? [fetch(:nginx_major_domain)] + Array(fetch(:nginx_domains)) : Array(fetch(:nginx_domains))
    # => set :lets_encrypt__www_domains,  true # also encrypt www. domains
    # => set :lets_encrypt_cron_log,      "#{shared_path}/log/lets_encrypt_cron.log"
    # => set :lets_encrypt_email,         "admin@example.com"
	# Client type: "new: certbot" or old "certbot-auto"
	# => set :lets_encrypt_client,        "new: certbot"
    
    
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => logs .. (if you need to check app log-files)
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :logs_roles,                 :web    # on roles ..
    # => set :logs_show_lines,            500     # show the last .. lines of log-file
    
    
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => monit
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    ## Status (monit is running or not .. activate monit hooks in deploy chain)
    # => set :monit_active,                         true
    ## Main-Instance (write monitrc?)
    # => set :monit_main_rc,                        true
    ## Monit-Processes (what should be monitored) = nginx pm2 postgresql pwa redis sidekiq thin website
    # => set :monit_processes,                      %w[nginx postgresql thin website]
    # => set :monit_name,                           "#{ fetch(:application) }_#{ fetch(:stage) }"
    ## Monit System
    # => set :monit_roles,                          :web
    # => set :monit_interval,                       30
    # => set :monit_bin,                            '/usr/bin/monit'
    ## Monit Log-File (Monit default: '/var/log/monit.log')
    # => set :monit_logfile,                        "#{shared_path}/log/monit.log"
    # => set :monit_idfile,                         '/var/lib/monit/id'
    # => set :monit_statefile,                      '/var/lib/monit/state'
    ## Downgrade to 5.16 on deploy (to fix action problems):
    # => set :monit_downgrade_on_deploy,            false
    ## Mailer
    # => set :monit_mail_server,                    "smtp.gmail.com"
    # => set :monit_mail_port,                      587
    # => set :monit_mail_authentication,            false # SSLAUTO|SSLV2|SSLV3|TLSV1|TLSV11|TLSV12
    # => set :monit_mail_username,                  "foo@example.com"
    # => set :monit_mail_password,                  "secret"
    # => set :monit_ignore,                         []  # %w[action pid]
    ## Change me!!
    # => set :monit_mail_to,                        "foo@example.com"
    # => set :monit_mail_from,                      "monit@foo.bar"
    # => set :monit_mail_reply_to,                  "support@foo.bar"
    ## Additional stuff for postrgres
    # => set :postgresql_roles,                     :db
    # => set :postgresql_pid,                       "/var/run/postgresql/9.1-main.pid"
    ## Additional stuff for thin (need secrets_key_base to be set)
    # => set :monit_thin_totalmem_mb,               300
    ## Additional stuff for sidekiq (need secrets_key_base to be set)
    # => set :monit_sidekiq_totalmem_mb,            300
    # => set :monit_sidekiq_timeout_sec,            90
    ## Additional App helpers (for in app processes like: thin, sidekiq)
    # => set :monit_app_worker_command,             "cd #{ current_path } ; #{fetch(:rvm_path)}/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec MONIT_CMD"
    #   needs to include at least MONIT_CMD, which gets replaced with current command
    #   ## RVM:
    #    - "cd #{ current_path } ; #{fetch(:rvm_path)}/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec MONIT_CMD"
    #   ## RVM1Caspistrano3:
    #    - "cd #{ current_path } ; #{fetch(:rvm1_auto_script_path)}/rvm-auto.sh #{fetch(:rvm1_ruby_version)} bundle exec MONIT_CMD"
    #   ## if all is root
    #    - "/usr/bin/env cd #{current_path} ; bundle exec MONIT_CMD"
    #   ## last option (if nothing else helps)
    #    - "/bin/su - #{@role.user} -c 'cd #{current_path} ; bundle exec MONIT_CMD'"
    ## WebClient
    # => set :monit_http_client,                    true
    # => set :monit_http_domain,                    false
    # => set :monit_http_port,                      2812
    # => set :monit_http_use_ssl,                   false
    # => set :monit_http_allow_self_certification,  false
    # => set :monit_http_pemfile,                   "/etc/monit/monit.pem"
    # => set :monit_http_username,                  "admin"
    # => set :monit_http_password,                  "monitor"
    ## Website
    # => set :monit_website_check_content,          false
    # => set :monit_website_check_path,             "/"
    # => set :monit_website_check_text,             "<!DOCTYPE html>"
    # => set :monit_website_check_timeout,          20
    # => set :monit_website_check_cycles,           3
    ## M/Monit
    # => set :monit_mmonit_url,                     false
    ## PM2 - JS - App
    # set :monit_pm2_app_name,                      "app"
    # set :monit_pm2_app_instances,                 1
    # set :monit_pm2_app_path,                      "/home/#{fetch(:user)}/pm2_app"
    # set :monit_pm2_pid_path,                      "/home/#{fetch(:user)}/.pm2/pids"
    # set :monit_pm2_start_script,                  "ecosystem.config.js"
    # set :monit_pm2_stage,                         "production"
    # set :monit_pm2_website,                       "example.com"
    # set :monit_pm2_website_ssl,                   false
    # set :pm2_roles,                               :web
    # set :monit_pm2_worker_role,                   :user
    ## if prefix for monit command is needed .. ie: "[ -s \"$HOME/.nvm/nvm.sh\" ] && \. \"$HOME/.nvm/nvm.sh\" ; nvm use 9.9.0 ; "
    # set :monit_pm2_worker_prefix,                 ""
    
    
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => nginx
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :app_server_ip,                   "127.0.0.1"
    ## all domains the app uses
    # => set :nginx_domains,                   []               # array of domains
    ## app is the default site for this server?
    # => set :default_site,                    false            # true | false
    ## all domains are redirected to this one, domain
    # => set :nginx_major_domain,              false            # "domain-name.tld" | false
    ## remove "www" from each request?
    # => set :nginx_remove_www,                true             # true | false
    ## how many (thin) server instances 
    # => set :app_instances,                   1                # number >= 1
    ## use wildcard for domain?
    # => set :nginx_domain_wildcard,           false
    ## redirect all subdomains?
    # => set :nginx_redirect_subdomains,       false
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
    ## ssl certificates
    # => set :nginx_ssl_cert,                  "/etc/ssl/certs/#{fetch(:application)}.crt"
    # => set :nginx_ssl_key,                   "/etc/ssl/private/#{fetch(:application)}.key"
    ## certs for other domains (when :nginx_major_domain is set)
    # => set :nginx_other_ssl_cert,            fetch(:nginx_ssl_cert)
    # => set :nginx_other_ssl_key,             fetch(:nginx_ssl_key)
    ## activate nginx hooks in deploy chain ?
    # => set :nginx_hooks,                     true
    ## Lets Encrypt - Challenge Path
    # => set :allow_well_known,                false
    ## only turn on, when rails :force_ssl is false !
    # => set :nginx_strict_security,           false
    # Diffie-Hellman settings
    # => set :nginx_use_diffie_hellman,        false
    # => set :nginx_diffie_hellman_param,      "/etc/ssl/certs/dhparam.pem"
    # => set :nginx_ssl_ciphers,               ".. long cipher string .." # check: https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
    
    
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => NginX - Proxy-Cache
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
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
## => pwa
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :pwa_roles,           :web
    # => set :pwa_application,     "#{fetch(:application)}_mobile"
    ## Pathes
    # => set :pwa_root_path,       "#{ current_path }/dist"
    # => set :pwa_local_path,      "./dist/"
    ## Site (nginx helper)
    # => set :pwa_domains,         []
    # => set :pwa_major_domain,    false
    # => set :pwa_ssl_domains,     fetch(:pwa_major_domain,false) ? [fetch(:pwa_major_domain)] + Array(fetch(:pwa_domains)) : Array(fetch(:pwa_domains))
    # => set :pwa_is_default_site, false
    # => set :pwa_nginx_hooks,     false
    # => set :pwa_nginx_template,  :default
    ## SSL (lets_encrypt helper)
    # => set :pwa_use_ssl,         false
    # => set :pwa_ssl_cert,        ""
    # => set :pwa_ssl_key,         ""
    
    
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
## => redirect_page
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :redirect_page_active,        false  # auto-include on each deploy ?
    # => set :redirect_old_domains,        []     # list of old sites to redirect (ie:  ['test.com', 'try.com'])
    # => set :redirect_old_ssl_domains,    []     # which old_sites have ssl (ie:  ['test.com'])
    # => set :redirect_new_domain,         ''     # domain of new page (ie:  https://example.com)
    # => set :redirect_new_name,           ''     # name of new page (ie:  example.com)
    # => set :redirect_ssl_cert,           ''     # path to cert for all old_ssl_domains
    # => set :redirect_ssl_key,            ''     # path to key for all old_ssl_domains
    ## deeper configs
    # => set :redirect_roles,              :app
    # => set :redirect_index_path,         "redirector"
    # => set :redirect_index_parent,       "#{ shared_path }"
    # => set :redirect_index_template,     :default
    # => set :redirect_nginx_template,     :default
    # => set :redirect_conf_name,          "redirector_#{fetch(:application)}_#{fetch(:stage)}"
    
    
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => redis
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :redis_roles,            :web
    # => set :redis_pid,              "/var/run/redis/redis-server.pid"
    
    
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => rvm  (if used)
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :rvm_type,               :user               # Defaults to: :auto .. (:auto | :system | :user)
    # => set :rvm_ruby_version,       '2.0.0-p247'        # Defaults to: 'default'
    # => set :rvm_custom_path,        '~/.myveryownrvm'   # only needed if not detected
    # => set :rvm_roles,              [:app, :web]
    # => set :rvm_map_bins,           %w{gem rake ruby bundle}
	# => set :rvm_path,               '/usr/local/rvm'
    
        
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => rvm1capistrano3  (if used)
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :rvm1_ruby_version,      "."
    # => set :rvm1_map_bins,          %w{rake gem bundle ruby}
    # => set :rvm1_alias_name,        fetch(:application)
    # => set :rvm1_auto_script_path,  "#{fetch(:deploy_to)}/rvm1scripts"
    
    
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => secrets
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :secrets_roles,       :app
    # => set :secrets_profile,     "bashrc" # "profile" | "bashrc" | "bach_profile" | "bash_login"
    # => set :secrets_key_base,    generate_secrect_key
    # => set :secrets_key_name,    "#{ fetch(:application) }_#{ fetch(:stage) }_SECRET_KEY_BASE".gsub(/-/, "_").gsub(/[^a-zA-Z_]/, "").upcase
    # => set :secrets_user_path,   { "/home/#{fetch(:user)}"
    # => set :secrets_set_both,    false  # also save usual SECRET_KEY_BASE 
    # => set :secrets_hooks,       true   # activate secrets hooks in setup chain ?
    # => set :secrets_set_env,     true   # also set in /etc/environment (for rvm usage)
    # => set :secrets_set_etc,     false  # also set in /etc/profile (for all machine users)
    # => set :secrets_symlink,     false  # auto symlink secrets.yml on each deploy (not needed if set in :linked_files)
    
    
    
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
    # => set :sidekiq_concurrency,     3      # how many threads to spawn
    ## If needed, you can set special queues and configure it seperately .. options:
    ##    - queue:      string    # => queue-name       (default: "default")
    ##    - processes:  integer   # => number processes (default: 1)
    ##    - worker:     integer   # => concurrency      (default: 7)
    ##      ie: [ {queue: "default", processes: 1, worker: 15}, {queue: "single", processes: 1, worker: 1} ]
    # => set :sidekiq_special_queues,   false
    # => set :sidekiq_queued_processes, []
    ## Rbenv and RVM integration
    # => set :rbenv_map_bins,          fetch(:rbenv_map_bins).to_a.concat(%w(sidekiq sidekiqctl))
    # => set :rvm_map_bins,            fetch(:rvm_map_bins).to_a.concat(%w(sidekiq sidekiqctl))
	
    
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
## => sidekiq6
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ##
    
    # => set :sidekiq_six_default_hooks,     true
    # => set :sidekiq_six_deamon_file,       "sidekiq_#{fetch(:application)}_#{fetch(:stage)}"
    # => set :sidekiq_six_timeout,           10
    # => set :sidekiq_six_roles,             :app
    # => set :sidekiq_six_processes,         1
    # => # Sidekiq queued processes:
    # => 
    # => set :sidekiq_six_special_queues,    false
    # => set :sidekiq_six_queued_processes,  []
    # => 
	## If needed you can set special queues and configure it seperately
    ## .. options:  
    ##    - queue:      string    # => queue-name       (default: "default")
    ##    - processes:  integer   # => number processes (default: 1)
    ##    - worker:     integer   # => concurrency      (default: 7)
    ## => [ { queue: "queue_name", processes: "count", worker: "count" }]
    # => 
    # => set :sidekiq_six_deamon_path,       "/lib/systemd/system"
    # => set :sidekiq_six_deamon_template,   :default
	# => 
    # => set :sidekiq_six_ruby_vm,           :system   	## ( :rvm | :rbenv | :system )
	# => set :sidekiq_six_user,              'deploy'   ## role-user
    
    
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


### ToDos

- clean up code
- write some generators
- testing


### LICENSE

This project rocks and uses MIT-LICENSE.