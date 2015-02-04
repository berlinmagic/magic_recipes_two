require "uri"
require "net/http"

namespace :load do
  task :defaults do
    set :slack_token,           -> { "xxx-xxx-xxx-xxx" }
    set :slack_channel,         -> { "xxx-xxx-xxx-xxx" }
    set :slack_text,            -> { "New Deployment on *#{ fetch(:stage) }* ... check:  #{fetch(:nginx_use_ssl) ? 'https': 'htpp'}://#{ fetch(:nginx_major_domain) ? fetch(:nginx_major_domain).gsub(/^\*?\./, "") : Array( fetch(:nginx_domains) ).first.gsub(/^\*?\./, "") }" }
    set :slack_username,        -> { "capistrano (#{fetch(:stage)})" }
    set :slack_production_icon, -> { "http://icons.iconarchive.com/icons/itzikgur/my-seven/128/Backup-IBM-Server-icon.png" }
    set :slack_staging_icon,    -> { "http://itekblog.com/wp-content/uploads/2012/07/railslogo.png" }
  end
end


namespace :deploy do
  
  desc "inform slack about upload"
  task :inform_slack do
    
    params = {  
                    token:      fetch(:slack_token),
                    channel:    fetch(:slack_channel),
                    text:       fetch(:slack_channel),
                    parse:      "full",
                    mrkdwn:     true,
                    username:   fetch(:slack_username),
                    icon_url:   "#{ fetch(:stage) == :production ? fetch(:slack_production_icon) : fetch(:slack_staging_icon) }"
              }
    
    Net::HTTP.post_form(URI.parse('https://slack.com/api/chat.postMessage'), params)
    
  end
  
  after :finished, :inform_slack
  
end
