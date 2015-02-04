require 'erb'

module Capistrano
  module MagicRecipes
    module BaseHelpers
      
      def template(from, to)
        # => erb = File.read(File.expand_path("../../../../config/deploy/templates/#{from}", __FILE__))
        # => upload ERB.new(erb).result(binding), to, via: :scp
        # on hosts do |host|
        #   upload! ERB.new(erb).result(binding), to
        # end
        erb = File.read(File.expand_path("../../../../config/deploy/templates/#{from}", __FILE__))
        config = ERB.new(erb).result(binding)
        upload! StringIO.new(config), to
      end

      def template_with_role(from, to, role = nil)
        [
            File.join('config', 'deploy', 'templates', "#{from}.rb.erb"),
            File.join('config', 'deploy', 'templates', "#{from}.rb"),
            File.join('config', 'deploy', 'templates', "#{from}.erb"),
            File.join('config', 'deploy', 'templates', "#{from}"),
            File.join('lib', 'capistrano', 'templates', "#{from}.rb.erb"),
            File.join('lib', 'capistrano', 'templates', "#{from}.rb"),
            File.join('lib', 'capistrano', 'templates', "#{from}.erb"),
            File.join('lib', 'capistrano', 'templates', "#{from}"),
            File.expand_path("../../templates/#{from}.rb.erb", __FILE__),
            File.expand_path("../../templates/#{from}.erb", __FILE__),
            File.expand_path("../../templates/#{from}", __FILE__)
        ].each do |path|
          if File.file?(path)
            erb = File.read(path)
            upload! StringIO.new(ERB.new(erb).result(binding)), to
            break
          end
        end
      end
      
    end
  end
end




