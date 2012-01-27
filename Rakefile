# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugins.delete :rubyforge
Hoe.plugin :minitest
Hoe.plugin :gemspec # `gem install hoe-gemspec`
Hoe.plugin :git     # `gem install hoe-git`

Hoe.spec 'rails_autolink' do
  developer('Aaron Patterson', 'aaron@tenderlovemaking.com')
  developer('Juanjo Bazan', 'jjbazan@gmail.com')
  developer('Akira Matsuda', 'ronnie@dio.jp')
  self.readme_file   = 'README.rdoc'
  self.history_file  = 'CHANGELOG.rdoc'
  self.extra_rdoc_files  = FileList['*.rdoc']
  self.extra_deps       << ['rails', '~> 3.1']
end

# vim: syntax=ruby
