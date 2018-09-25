# MagicRecipesTwo

Our most used recipes for Capistrano-3!


### ChangeLog:


**Version 0.0.85**
- add **pwa module** for mobile (spa/pwa) support (nginx + lets_encrypt)
- add `monit:downgrade` methods (fix action problem)
- add `lets_encrypt:certonly_expand` to add more domains
- add `nginx:check_status` to check service status
- add `nginx:check_status` to check service status
- add `nginx:fix_port80` to fix port Problem: 0.0.0.0:80 failed (98: Address already in use)
- add `nginx:fix_port443` to fix port Problem: 0.0.0.0:443 failed (98: Address already in use)


**Caution**
- broken Versions: **0.0.81 - 0.0.84**


**Version 0.0.80**
- create diffie hellman path before upload


**Version 0.0.79**
- upload diffie hellman to `:nginx_diffie_hellman_param`


**Version 0.0.78:**
- add `:nginx_redirect_subdomains` config, to control nginx redirection


**Version 0.0.77:**
- `:monit_ingore` specify events you don't wanna get emails for

**Version 0.0.76:**
- **Remove useless monit secret-helpers:**
- `:monit_thin_with_secret`, `:monit_sidekiq_with_secret`
- **Add App-command-wrapper for monit** (i.e. for: thin, sidekiq)
- `:monit_app_worker_command`
  

**Caution**
- broken Version: **0.0.75**
  

**Version 0.0.70:**
- **Renamed and combined some stuff:**
- `:lets_encrypt_renew_hour` **=** `:lets_encrypt_renew_hour1` + `:lets_encrypt_renew_hour2`
 

**Version 0.0.68:**
- Better handling of sudo add secret to env
 

**Version 0.0.67:**
- **Removed some useless stuff:**
- `:nginx_remove_https` .. need realy possible, so its gone
- **Renamed and combined some stuff:**
- `:nginx_ssl_cert` **=** `:nginx_ssl_certificate_path` + `:nginx_ssl_certificate`
- `:nginx_ssl_key` **=** `:nginx_ssl_certificate_key_path` + `:nginx_ssl_certificate_key`
- `:nginx_other_ssl_cert` **=** `:nginx_ssl_certificate_path` + `:nginx_old_ssl_certificate`
- `:nginx_other_ssl_key` **=** `:nginx_ssl_certificate_key_path` + `:nginx_old_ssl_certificate_key`
- depreacated: `:nginx_ssl_certificate_path`, `:nginx_ssl_certificate`, `:nginx_old_ssl_certificate`, `:nginx_ssl_certificate_key_path`, `:nginx_ssl_certificate_key`, `:nginx_old_ssl_certificate_key`
- `:nginx_diffie_hellman_param` **=** `:nginx_ssl_dh_path` + `:nginx_ssl_dh_file`
- **Renamed some stuff:**
- `:nginx_ssl_diffie_hellman` => `:nginx_use_diffie_hellman`
- `:nginx_strict_transport_security_header` => `:nginx_strict_security`
- **Add new Stuff**
- `:nginx_ssl_ciphers` to change the cipher suite *(needs `:nginx_use_diffie_hellman`)*
 

**Version 0.0.65:**
- cover for *Strict Transport Security (HSTS): Invalid .. Server provided more than one HSTS header*
- add `:nginx_strict_transport_security_header` => set *false*, when rails `:force_ssl` is *true*!
- to get **A+** again on [ssllabs](https://www.ssllabs.com/ssltest/analyze.html) (was A, when `:force_ssl` = true)
 

**Version 0.0.64:**
- got **A+ SSL Report** on [ssllabs](https://www.ssllabs.com/ssltest/analyze.html) for certificate created with this gem
- add check cron-log job for lets encrypt
 

**Version 0.0.60:**
- add **Lets Encrypt** actions
- add special nginx security lines, as described by [digital-ocean](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04)
- add **Diffie-Hellman** actions
 

**Version 0.0.57:**
- **Lets Encrypt** allow *.well-known* pathes via nginx with `:allow_well_known`
 

**Version 0.0.52:**
- data-dump gets packed *(tar.gz)* before download
 

**Version 0.0.50:**
- new `:sidekiq_special_queues` .. use special options per queue?
- new `:sidekiq_queued_processes` .. special options per queue
- *options per queue:*
- `queue`     = queue-name *str* .. default: "default"
- `processes` = number of processes *int* .. default: 1
- `worker`    = number of worker (concurrency) *int* .. default: 7
- ie: `[ {queue: "default", processes: 1, worker: 15}, {queue: "single", processes: 1, worker: 1} ]`
 

**Caution**
- broken Versions: **0.0.45 - 0.0.49**
 

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
 
 