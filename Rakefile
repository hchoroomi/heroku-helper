require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/heroku-helper'

Hoe.plugin :newgem
# Hoe.plugin :website
# Hoe.plugin :cucumberfeatures

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'heroku-helper' do
  self.developer 'ELC Technologies', 'hchoroomi@elctech.com'
  self.rubyforge_name       = self.name
  # self.extra_deps         = [['activesupport','>= 2.0.2']]

end

#require 'newgem/tasks'
#Dir['tasks/**/*.rake'].each { |t| load t }