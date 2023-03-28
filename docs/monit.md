# Monit

-----
> ### Requirements
> 
> Capfile
> ```ruby
> require 'capistrano/magic_recipes/monit'
> ```
-----


Status (monit is running or not .. activate monit hooks in deploy chain)
```ruby	
 set :monit_active,                         true
```

Main-Instance (write monitrc?) .. usefull if more sites share one server
```ruby	
 set :monit_main_rc,                        true
```


Monit-Processes (what should be monitored)
```ruby
 set :monit_processes,                      %w[nginx postgresql thin website] # nginx pm2 postgresql pwa redis sidekiq thin website website_checks
 set :monit_ignore,                         []  # %w[action pid]
```


Monit-Name (showed in monit-page)
```ruby
 set :monit_name,                           "#{ fetch(:application) }_#{ fetch(:stage) }"
```



Monit-System
```ruby
 set :monit_roles,                          :web
 set :monit_interval,                       30
 set :monit_bin,                            '/usr/bin/monit'
```



Monit Log-File (Monit default: '/var/log/monit.log')
```ruby
 set :monit_logfile,                        "#{shared_path}/log/monit.log"
 set :monit_idfile,                         '/var/lib/monit/id'
 set :monit_statefile,                      '/var/lib/monit/state'
```


-----


MONIT-Mailer
```ruby
 set :monit_mail_server,                    "smtp.gmail.com"
 set :monit_mail_port,                      587
 set :monit_mail_authentication,            false # SSLAUTO|SSLV2|SSLV3|TLSV1|TLSV11|TLSV12
 set :monit_mail_username,                  "foo@example.com"
 set :monit_mail_password,                  "secret"
 set :monit_mail_to,                        "foo@example.com"
 set :monit_mail_from,                      "monit@foo.bar"
 set :monit_mail_reply_to,                  "support@foo.bar"
```


MONIT-WEB-VIEW
```ruby
 ## WebClient
 set :monit_http_client,                    true
 set :monit_http_port,                      2812
 set :monit_http_username,                  "admin"
 set :monit_http_password,                  "monitor"
 # use a domain / subdomain for monit?
 set :monit_webclient,             					false
 set :monit_webclient_domain,      					false
 set :monit_webclient_use_ssl,     					false
 set :monit_webclient_ssl_cert,    					false
 set :monit_webclient_ssl_key,     					false
 set :monit_nginx_template,        					:default
```


-----


M/MONIT URL (test-phase BETA)
```ruby
 set :monit_mmonit_url,                     false
```



POSTGRESQL
```ruby
 set :monit_pg_pid,                       	"/var/run/postgresql/12-main.pid"
```

THIN
```ruby
 set :monit_thin_totalmem_mb,               300
```


sidekiq (need secrets_key_base to be set)
```ruby
 set :monit_sidekiq_totalmem_mb,            300
 set :monit_sidekiq_timeout_sec,            90
```


-----



Website
```ruby
 set :monit_website_check_content,          false
 set :monit_website_check_path,             "/"
 set :monit_website_check_text,             "<!DOCTYPE html>"
 set :monit_website_check_timeout,          20
 set :monit_website_check_cycles,           3
```



PM2 - JS - App
```ruby
 set :monit_pm2_app_name,                      "app"
 set :monit_pm2_app_instances,                 1
 set :monit_pm2_app_path,                      "/home/#{fetch(:user)}/pm2_app"
 set :monit_pm2_pid_path,                      "/home/#{fetch(:user)}/.pm2/pids"
 set :monit_pm2_start_script,                  "ecosystem.config.js"
 set :monit_pm2_stage,                         "production"
 set :monit_pm2_website,                       "example.com"
 set :monit_pm2_website_ssl,                   false
 set :pm2_roles,                               :web
 set :monit_pm2_worker_role,                   :user
 ## if prefix for monit command is needed .. ie: "[ -s \"$HOME/.nvm/nvm.sh\" ] && \. \"$HOME/.nvm/nvm.sh\" ; nvm use 9.9.0 ; "
 set :monit_pm2_worker_prefix,                 ""
```





-----


Additional App helpers (for in app processes like: thin, sidekiq)
```ruby
  set :monit_app_worker_command, "cd #{ current_path } ; #{fetch(:rvm_path)}/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec MONIT_CMD"
  # needs to include at least MONIT_CMD, which gets replaced with current command
  ## RVM:
  # - "cd #{ current_path } ; #{fetch(:rvm_path)}/bin/rvm #{fetch(:rvm_ruby_version)} do bundle exec MONIT_CMD"
  ## RVM1Caspistrano3:
  # - "cd #{ current_path } ; #{fetch(:rvm1_auto_script_path)}/rvm-auto.sh #{fetch(:rvm1_ruby_version)} bundle exec MONIT_CMD"
  ## if all is root
  # - "/usr/bin/env cd #{current_path} ; bundle exec MONIT_CMD"
  ## last option (if nothing else helps)
  # - "/bin/su - #{@role.user} -c 'cd #{current_path} ; bundle exec MONIT_CMD'"
```

 

