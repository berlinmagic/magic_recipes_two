namespace :deploy do
  
  desc "inform slack about upload"
  task :inform_slack do
    
    require "uri"
    require "net/http"
    
    server_pic = "http://icons.iconarchive.com/icons/itzikgur/my-seven/128/Backup-IBM-Server-icon.png"
    rails_pic = "http://itekblog.com/wp-content/uploads/2012/07/railslogo.png"
    
    params = {  
                    token: "xoxp-2796833420-2797515550-2823404703-d94440",
                    channel: "C02PELF79",
                    text: "New Deployment on *#{ fetch(:stage) }* ... check:  #{fetch(:nginx_use_ssl) ? 'https': 'htpp'}://#{ fetch(:nginx_major_domain) ? fetch(:nginx_major_domain).gsub(/^\*?\./, "") : Array( fetch(:nginx_domains) ).first.gsub(/^\*?\./, "") }",
                    parse: "full",
                    mrkdwn: true,
                    username: "capistrano (#{fetch(:stage)})",
                    icon_url: "#{ fetch(:stage) == :production ? server_pic : rails_pic }"
              }
    Net::HTTP.post_form(URI.parse('https://slack.com/api/chat.postMessage'), params)
    
  end
  
  after :finished, :inform_slack
  
end
