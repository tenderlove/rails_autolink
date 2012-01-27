# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rails_autolink"
  s.version = "1.0.3.1.20120127181656"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Patterson", "Juanjo Bazan", "Akira Matsuda"]
  s.date = "2012-01-27"
  s.description = "This is an extraction of the `auto_link` method from rails.  The `auto_link`\nmethod was removed from Rails in version Rails 3.1.  This gem is meant to\nbridge the gap for people migrating."
  s.email = ["aaron@tenderlovemaking.com", "jjbazan@gmail.com", "ronnie@dio.jp"]
  s.extra_rdoc_files = ["Manifest.txt", "CHANGELOG.rdoc", "README.rdoc"]
  s.files = [".autotest", "CHANGELOG.rdoc", "Gemfile", "Manifest.txt", "README.rdoc", "Rakefile", "lib/rails_autolink.rb", "lib/rails_autolink/helpers.rb", "test/test_rails_autolink.rb", ".gemtest"]
  s.homepage = "http://github.com/tenderlove/rails_autolink"
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "rails_autolink"
  s.rubygems_version = "1.8.15"
  s.summary = "This is an extraction of the `auto_link` method from rails"
  s.test_files = ["test/test_rails_autolink.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["<= 3.2.1", ">= 3.1"])
      s.add_development_dependency(%q<minitest>, ["~> 2.11"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_development_dependency(%q<hoe>, ["~> 2.13"])
    else
      s.add_dependency(%q<rails>, ["<= 3.2.1", ">= 3.1"])
      s.add_dependency(%q<minitest>, ["~> 2.11"])
      s.add_dependency(%q<rdoc>, ["~> 3.10"])
      s.add_dependency(%q<hoe>, ["~> 2.13"])
    end
  else
    s.add_dependency(%q<rails>, ["<= 3.2.1", ">= 3.1"])
    s.add_dependency(%q<minitest>, ["~> 2.11"])
    s.add_dependency(%q<rdoc>, ["~> 3.10"])
    s.add_dependency(%q<hoe>, ["~> 2.13"])
  end
end
