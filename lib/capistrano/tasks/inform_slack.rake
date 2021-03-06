require "uri"
require "net/http"

namespace :load do
  task :defaults do
    set :slack_token,           -> { "xxx-xxx-xxx-xxx" }
    set :slack_channel,         -> { "xxx-xxx-xxx-xxx" }
    set :slack_text,            -> { "*#{ fetch(:application) }* new Deployment on *#{ fetch(:stage) }* ... check:  #{fetch(:nginx_use_ssl) ? 'https': 'http'}://#{ fetch(:nginx_major_domain) ? fetch(:nginx_major_domain).gsub(/^\*?\./, "") : Array( fetch(:nginx_domains) ).first.gsub(/^\*?\./, "") }" }
    set :slack_username,        -> { "#{ fetch(:application) }-Bot (#{fetch(:stage)})" }
    set :slack_production_icon, -> { "http://icons.iconarchive.com/icons/itzikgur/my-seven/128/Backup-IBM-Server-icon.png" }
    set :slack_staging_icon,    -> { "http://icons.iconarchive.com/icons/oxygen-icons.org/oxygen/128/Mimetypes-application-x-ruby-icon.png" }
  end
end


namespace :deploy do
  
  desc "inform slack about upload"
  task :inform_slack do
    
    params = {  
                    token:      fetch(:slack_token),
                    channel:    fetch(:slack_channel),
                    text:       fetch(:slack_text),
                    parse:      "full",
                    mrkdwn:     true,
                    username:   fetch(:slack_username),
                    icon_url:   "#{ fetch(:stage) == :production ? fetch(:slack_production_icon) : fetch(:slack_staging_icon) }"
              }
    
    Net::HTTP.post_form(URI.parse('https://slack.com/api/chat.postMessage'), params)
    
  end
  
  after :finished, :inform_slack
  
end
