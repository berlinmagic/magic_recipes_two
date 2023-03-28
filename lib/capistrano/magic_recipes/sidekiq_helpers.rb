module Capistrano
  module MagicRecipes
    module SidekiqHelpers
      
      
      def for_each_process(reverse = false, &block)
        pids = processes_deamones
        pids.reverse! if reverse
        pids.each_with_index do |service_file, idx|
          within fetch(:sidekiq_six_deamon_path) do
            yield(service_file, idx)
          end
        end
      end
  
      def processes_deamones
        deamons = []
        if fetch(:sidekiq_six_special_queues)
          fetch(:sidekiq_six_queued_processes, []).each do |qp|
            counter = (qp[:processes] && qp[:processes].to_i > 0 ? qp[:processes].to_i : 1)
            if counter > 1
              counter.times do |idx|
                deamons.push "#{ fetch(:sidekiq_six_deamon_file) }-#{ qp[:queue] }-#{ idx }"
              end
            else
              deamons.push "#{ fetch(:sidekiq_six_deamon_file) }-#{ qp[:queue] }"
            end
          end
        else
          counter = fetch(:sidekiq_six_processes).to_i 
          if counter > 1
            counter.times do |idx|
              deamons.push "#{ fetch(:sidekiq_six_deamon_file) }-#{ idx }"
            end
          else
            deamons.push "#{ fetch(:sidekiq_six_deamon_file) }"
          end
        end
        deamons
      end
  
      def sidekiq_special_config(idx)
        if fetch(:sidekiq_six_special_queues)
          settingz = []
          fetch(:sidekiq_six_queued_processes).each do |that|
            (that[:processes] && that[:processes].to_i > 0 ? that[:processes].to_i : 1 ).to_i.times do
              sttng_hash = {}
              sttng_hash[:queue] = that[:queue] ? that[:queue] : "default"
              sttng_hash[:concurrency] = that[:worker] && that[:worker].to_i > 0 ? that[:worker].to_i : 7
              settingz.push( sttng_hash )
            end
          end
          settingz[ idx.to_i ]
        else
          {}
        end
      end
      
      
    end
  end
end




