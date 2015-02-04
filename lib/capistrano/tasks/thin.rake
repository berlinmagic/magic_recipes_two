# => namespace :deploy do
# =>   COMMANDS = %w(start stop restart)
# => 
# =>   COMMANDS.each do |command|
# =>     task command do
# =>       on roles(:app), in: :sequence, wait: 5 do
# =>         within current_path do
# =>           execute :bundle, "exec thin #{command} -O --tag '#{fetch(:application)} #{fetch(:stage)}' -C config/thin/#{fetch(:stage)}.yml"
# =>         end
# =>       end
# =>     end
# =>   end
# => 
# =>   # RVM integration
# =>   if Gem::Specification::find_all_by_name('capistrano-rvm').any?
# =>     COMMANDS.each { |c| before c, 'rvm:hook' }
# =>   end
# => end

namespace :load do
  task :defaults do
    set :thin_path, -> { '/etc/thin' }
    set :thin_roles, -> { :web }
  end
end



namespace :thin do
  
  # desc "rewrite thin-configurations"
  # task :reconf, roles: :app do
  #   template "thin_app_yml.erb", "#{fetch(:current_path)}/config/thin_app_#{fetch(:stage)}.yml"
  #   run "#{sudo} rm -f #{fetch(:thin_path)}/thin_#{fetch(:application)}_#{fetch(:stage)}*"
  #   run "#{sudo} ln -sf #{fetch(:current_path)}/config/thin_app_#{fetch(:stage)}.yml #{fetch(:thin_path)}/thin_#{fetch(:application)}_#{fetch(:stage)}.yml"
  # end
  
  desc "rewrite thin-configurations"
  task :reconf => ['nginx:load_vars'] do
    on release_roles fetch(:thin_roles) do
      within current_path do
        config_file = File.expand_path("../../../../config/deploy/templates/thin_app_yml.erb", __FILE__)
        config = ERB.new(File.read(config_file)).result(binding)
        upload! StringIO.new(config), '/tmp/thin_app.yml'
        
        execute :sudo, :pwd
        
        execute :sudo, :mv, '/tmp/thin_app.yml', "config/thin_app_#{fetch(:stage)}.yml"
        execute :sudo, :rm, ' -f', "#{fetch(:thin_path)}/thin_#{fetch(:application)}_#{fetch(:stage)}*"
        execute :sudo, :ln, ' -sf', "#{current_path}/config/thin_app_#{fetch(:stage)}.yml", "#{fetch(:thin_path)}/thin_#{fetch(:application)}_#{fetch(:stage)}.yml"
      end
    end
  end
  
  
  %w[start stop restart].each do |command|
    desc "#{command} thin"
    task command => ['nginx:load_vars'] do
      on release_roles fetch(:thin_roles) do
        within current_path do
          execute :bundle, :exec, :thin, "#{command} -C config/thin_app_#{fetch(:stage)}.yml"
        end
      end
    end
  end
  
  
  
  # => # Start / Stop / Restart Thin
  # => %w[start stop restart].each do |command|
  # =>   desc "#{command} thin"
  # =>   task command, roles: :app do
  # =>     reconf
  # =>     if use_rvm
  # =>       run <<-CMD
  # =>         #{rvm_cmd} && 
  # =>         cd #{current_path} && 
  # =>         bundle exec thin #{command} -C config/thin_app.yml
  # =>       CMD
  # =>     else
  # =>       run "bundle exec thin #{command} -C config/thin_app.yml"
  # =>     end
  # =>   end
  # =>   # before "nginx:#{command}", "thin:#{command}"
  # => end
  # => 
  # => before "nginx:start", "thin:start"
  # => before "nginx:stop", "thin:stop"
  
end

after 'deploy:published', nil do
  on release_roles fetch(:thin_roles) do
    invoke "thin:reconf"
    invoke "thin:restart"
  end
end
