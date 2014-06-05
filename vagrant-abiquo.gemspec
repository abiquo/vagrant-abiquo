# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-abiquo/version'

Gem::Specification.new do |gem|
  gem.name          = "vagrant-abiquo"
  gem.version       = VagrantPlugins::Abiquo::VERSION
  gem.authors       = ["Daniel Beneyto"]
  gem.email         = ["daniel.beneyto@abiquo.com"]
  gem.description   = %q{Enables Vagrant to manage Abiquo instances}
  gem.summary       = gem.description

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rest-client", ">= 1.6.7"
  gem.add_dependency "json"
  gem.add_dependency "log4r"
end
