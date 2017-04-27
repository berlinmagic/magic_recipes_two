$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "capistrano/magic_recipes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "magic_recipes_two"
  s.version     = Capistrano::MagicRecipes::VERSION
  s.authors     = ["Torsten Wetzel"]
  s.email       = ["torstenwetzel@berlinmagic.com"]
  s.homepage    = "https://github.com/berlinmagic/magic_recipes_two"
  s.summary     = "Some recipes for rails-4 and capistrano-3."
  s.description = "MagicRecipesTwo contains our most used deployment recipes for Capistrano-3."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.require_paths = ["lib"]

  s.add_dependency "rails",                 ">= 3.2"
  s.add_dependency "capistrano",            ">= 3.2"
  s.add_dependency "capistrano-bundler",    ">= 1.1"
  s.add_dependency "capistrano-rails",      ">= 1.1"
  s.add_dependency "rvm1-capistrano3",      ">= 1.4"
  s.add_dependency "capistrano-postgresql", ">= 4.2"
  s.add_dependency "yaml_db"

  s.add_development_dependency "sqlite3"
  
  
end
