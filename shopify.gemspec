# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shopify}
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Parker"]
  s.date = %q{2009-04-16}
  s.description = %q{Easily communicate with Shopify.com's restful API.}
  s.email = %q{gems@behindlogic.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/shopify/extlib/assertions.rb", "lib/shopify/extlib/class.rb", "lib/shopify/extlib/hash.rb", "lib/shopify/extlib/hook.rb", "lib/shopify/extlib/inflection.rb", "lib/shopify/extlib/logger.rb", "lib/shopify/extlib/object.rb", "lib/shopify/extlib/pathname.rb", "lib/shopify/extlib/rubygems.rb", "lib/shopify/extlib/string.rb", "lib/shopify/extlib/time.rb", "lib/shopify/extlib.rb", "lib/shopify/support.rb", "lib/shopify.rb", "LICENSE", "README.textile"]
  s.files = ["CHANGELOG", "lib/shopify/extlib/assertions.rb", "lib/shopify/extlib/class.rb", "lib/shopify/extlib/hash.rb", "lib/shopify/extlib/hook.rb", "lib/shopify/extlib/inflection.rb", "lib/shopify/extlib/logger.rb", "lib/shopify/extlib/object.rb", "lib/shopify/extlib/pathname.rb", "lib/shopify/extlib/rubygems.rb", "lib/shopify/extlib/string.rb", "lib/shopify/extlib/time.rb", "lib/shopify/extlib.rb", "lib/shopify/support.rb", "lib/shopify.rb", "LICENSE", "Manifest", "README.textile", "shopify.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/dcparker/shopify/tree}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Shopify", "--main", "README.textile"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{shopify}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Easily communicate with Shopify.com's restful API.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<jnunemaker-httparty>, ["= 0.3.1"])
    else
      s.add_dependency(%q<jnunemaker-httparty>, ["= 0.3.1"])
    end
  else
    s.add_dependency(%q<jnunemaker-httparty>, ["= 0.3.1"])
  end
end
