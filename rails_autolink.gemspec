require File.expand_path "#{File.dirname(__FILE__)}/lib/rails_autolink/version"

Gem::Specification.new do |s|
  s.name = 'rails_autolink'
  s.version = RailsAutolink::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')
  s.authors = ['Aaron Patterson', 'Juanjo Bazan', 'Akira Matsuda']
  s.email = 'aaron@tenderlovemaking.com'
  s.homepage = 'https://github.com/tenderlove/rails_autolink'
  s.summary =  'Automatic generation of html links in texts'
  s.description = 'This is an extraction of the `auto_link` method from rails. The `auto_link` method was removed from Rails in version Rails 3.1. This gem is meant to bridge the gap for people migrating.'
  s.metadata = {
    'bug_tracker_uri' => "#{s.homepage}/issues",
    'changelog_uri' => "#{s.homepage}/blob/v#{s.version}/CHANGELOG.rdoc",
    'documentation_uri' => "https://www.rubydoc.info/gems/#{s.name}/#{s.version}",
    'homepage_uri' => s.homepage,
    'source_code_uri' => "#{s.homepage}/tree/v#{s.version}"
  }

  rails_constraint = '> 3.1'
  s.add_dependency 'actionview', rails_constraint
  s.add_dependency 'activesupport', rails_constraint
  s.add_dependency 'railties', rails_constraint
  s.required_ruby_version = '>= 1.9.3'
  s.license = 'MIT'

  s.files = Dir.glob("{test,lib/**/*}") + `git ls-files -z`.split("\0")
end
