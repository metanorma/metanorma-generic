lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "metanorma/acme/version"

Gem::Specification.new do |spec|
  spec.name          = "metanorma-acme"
  spec.version       = Metanorma::Acme::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Metanorma for the (fictitious) Acme Corp."
  spec.description   = <<~DESCRIPTION
    Metanorma for the (fictitious) Acme Corp.

    This gem is meant to be customised for any downstream use.
  DESCRIPTION

  spec.homepage      = "https://github.com/riboseinc/metanorma-acme"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "asciidoctor", "~> 1.5.7"
  spec.add_dependency "htmlentities", "~> 4.3.4"
  spec.add_dependency "ruby-jing"
  spec.add_dependency "metanorma-standoc", "~> 1.0.8"
  spec.add_dependency "isodoc", "~> 0.9.0"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "= 0.54.0"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_development_dependency "metanorma", "~> 0.3.0"
  spec.add_development_dependency "metanorma-cli", "~> 1.0.3"
end
