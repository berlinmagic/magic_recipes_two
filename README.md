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
## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
## MagicRecipes

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

## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## ## 
```


## Variables

##### db
- **db_roles**

##### inform_slack
- **slack_token**
- **slack_channel**
- **slack_text**
- **slack_username**
- **slack_production_icon**
- **slack_staging_icon**

##### monit
- **monit_roles**
- **monit_interval**
- *Mailer:*
- **monit_mail_server**
- **monit_mail_port**
- **monit_mail_authentication**
- **monit_mail_username**
- **monit_mail_password**
- **monit_mail_to**
- **monit_mail_from**
- **monit_mail_reply_to**
- *Additional stuff for postrgres:*
- **postgresql_roles**
- **postgresql_pid**
- *WebClient:*
- **monit_http_client**
- **monit_http_domain**
- **monit_http_port**
- **monit_http_use_ssl**
- **monit_http_pemfile**
- **monit_http_username**
- **monit_http_password**

##### nginx
- **app_instances**
- **app_server_ip**
- **default_site**
- **nginx_domains**
- **nginx_service_path**
- **nginx_roles**
- **nginx_log_path**
- **nginx_root_path**
- **nginx_static_dir**
- **nginx_sites_enabled**
- **nginx_sites_available**
- **nginx_template**
- **nginx_use_ssl**
- **nginx_ssl_certificate**
- **nginx_ssl_certificate_path**
- **nginx_ssl_certificate_key**
- **nginx_ssl_certificate_key_path**

##### redis
- **redis_roles**
- **redis_pid**

##### secrets
- **secrets_roles**

##### sidekiq
- **sidekiq_default_hooks**
- **sidekiq_pid**
- **sidekiq_env**
- **sidekiq_log**
- **sidekiq_timeout**
- **sidekiq_roles**
- **sidekiq_processes**
- *Rbenv and RVM integration:*
- **rbenv_map_bins**
- **rvm_map_bins**

##### thin
- **thin_path**
- **thin_roles**

---

This project rocks and uses MIT-LICENSE.