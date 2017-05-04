
namespace :load do
  task :defaults do
    set :logs_roles,        -> { :web }
    set :logs_show_lines,   -> { 500 }
  end
end


namespace :logs do
  
  ["rails", "sidekiq", "monit", "nginx-access", "nginx-error", "lets_encrypt_cron"].each do |that|
    
    desc "show #{that == 'lets_encrypt_cron' ? 'Lets Encrypt cron-job' : that} logs"
    task that do
      on release_roles fetch(:logs_roles, :web) do
        within shared_path do
          execute :tail, "-n #{ fetch(:logs_show_lines, 100) } log/#{ that == 'rails' ? fetch(:stage) : that }.log"
        end
      end
    end
    
  end
  
  3.times do |x|
    
    desc "show thin instance-#{x} logs"
    task "thin#{x}" do
      on release_roles fetch(:logs_roles, :web) do
        within shared_path do
          begin
            execute :tail, "-n #{ fetch(:logs_show_lines, 100) } log/thin_#{fetch(:application)}_#{fetch(:stage)}.#{x}.log"
          rescue SSHKit::Command::Failed
            # If gems are not installed eq(first deploy) and sidekiq_default_hooks as active
            warn "thin_#{fetch(:application)}_#{fetch(:stage)}.#{x}.log => not found! .. (may not exist)"
          end
        end
      end
    end
    
  end
  
  
end



