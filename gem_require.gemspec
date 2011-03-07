# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  
  gem.name = "gem_require"
  gem.version = "0.0.5"
  gem.platform = Gem::Platform::RUBY

  gem.homepage = "http://github.com/mdub/gem_require"
  gem.authors = ["Mike Williams"]
  gem.email = "mdub@dogbiscuit.org"

  gem.summary = "Add the 'gem require' command"
  gem.description = "This gem adds the `gem require` command.  It's almost identical to `gem install`,
except that it does nothing if the specified gem is already installed."

  gem.files = Dir["lib/**/*"]
  gem.require_paths = ["lib"]
  
end
