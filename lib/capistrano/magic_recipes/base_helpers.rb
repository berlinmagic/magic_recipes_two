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
        # => erb = File.read(File.expand_path("../../../../config/deploy/templates/#{from}", __FILE__))
        if File.file?(from)
          config = ERB.new( File.read(from) ).result(binding)
          upload! StringIO.new(config), to
        end
      end
      
      def magic_template(from, to)
        erb = get_template_file(from)
        upload! StringIO.new( ERB.new(erb).result(binding) ), to
      end
      
      
      def magic_render(tmpl)
        erb = get_template_file(tmpl)
        ERB.new(erb).result(binding)
      end
      
      
      def generate_secrect_key
        SecureRandom.hex(82)
      end

      def template_with_role(from, to, role = nil)
        erb = get_template_file(from)
        upload! StringIO.new(ERB.new(erb).result(binding)), to
      end
      
      
      def get_template_file( from )
        [
            File.join('config', 'deploy', 'templates', "#{from}.rb.erb"),
            File.join('config', 'deploy', 'templates', "#{from}.rb"),
            File.join('config', 'deploy', 'templates', "#{from}.erb"),
            File.join('config', 'deploy', 'templates', "#{from}"),
            File.join('lib', 'capistrano', 'templates', "#{from}.rb.erb"),
            File.join('lib', 'capistrano', 'templates', "#{from}.rb"),
            File.join('lib', 'capistrano', 'templates', "#{from}.erb"),
            File.join('lib', 'capistrano', 'templates', "#{from}"),
            File.expand_path("../../../generators/capistrano/magic_recipes/templates/#{from}.rb.erb", __FILE__),
            File.expand_path("../../../generators/capistrano/magic_recipes/templates/#{from}.rb", __FILE__),
            File.expand_path("../../../generators/capistrano/magic_recipes/templates/#{from}.erb", __FILE__),
            File.expand_path("../../../generators/capistrano/magic_recipes/templates/#{from}", __FILE__)
        ].each do |path|
          return File.read(path) if File.file?(path)
        end
        # false
        raise "File '#{from}' was not found!!!"
      end
      
      
    end
  end
end




