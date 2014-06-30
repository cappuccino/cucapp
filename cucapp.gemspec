require 'rubygems'
require 'rubygems/package_task'

spec = Gem::Specification.new do |s|
  s.name = "cucapp"
  s.version = "0.0.1"
  s.author = "Alexandre Wilhelm"
  s.email = "alexandre.wilhelmfr@gmail.com"
  s.platform = Gem::Platform::RUBY
  s.summary = "An interface between Cucumber and Cappuccino"
  s.add_dependency("cucumber", "~> 1.3")
  s.add_dependency("thin", "~> 1.6")
  s.add_dependency("nokogiri", "~> 1.6")
  s.add_dependency("json", "~> 1.8")
  s.add_dependency("launchy", "~> 2.4")
end
