# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{shopify}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Parker"]
  s.cert_chain = ["/Users/daniel/.gem_keys/gem-public_cert.pem"]
  s.date = %q{2008-12-09}
  s.description = %q{Easily communicate with Shopify.com's restful API.}
  s.email = %q{gems@behindlogic.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/shopify/address.rb", "lib/shopify/order.rb", "lib/shopify/product.rb", "lib/shopify/sale.rb", "lib/shopify/session.rb", "lib/shopify/shop.rb", "lib/shopify/site.rb", "lib/shopify.rb", "LICENSE", "README"]
  s.files = ["CHANGELOG", "lib/shopify/address.rb", "lib/shopify/order.rb", "lib/shopify/product.rb", "lib/shopify/sale.rb", "lib/shopify/session.rb", "lib/shopify/shop.rb", "lib/shopify/site.rb", "lib/shopify.rb", "LICENSE", "Manifest", "README", "shopify.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/dcparker/shopify/tree}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Shopify", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{shopify}
  s.rubygems_version = %q{1.3.1}
  s.signing_key = %q{/Users/daniel/.gem_keys/gem-private_key.pem}
  s.summary = %q{Easily communicate with Shopify.com's restful API.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activeresource>, [">= 0", "= 2.1.0"])
      s.add_development_dependency(%q<echoe>, [">= 0"])
    else
      s.add_dependency(%q<activeresource>, [">= 0", "= 2.1.0"])
      s.add_dependency(%q<echoe>, [">= 0"])
    end
  else
    s.add_dependency(%q<activeresource>, [">= 0", "= 2.1.0"])
    s.add_dependency(%q<echoe>, [">= 0"])
  end
end
