lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "asciidoctor/rsd/version"

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-rsd"
  spec.version       = Asciidoctor::Rsd::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "asciidoctor-rsd lets you write RSD in AsciiDoc."
  spec.description   = <<~DESCRIPTION
    asciidoctor-rsd lets you write RSD in AsciiDoc syntax.

    This gem is in active development.
  DESCRIPTION

  spec.homepage      = "https://github.com/riboseinc/asciidoctor-rsd"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "asciidoctor", "~> 1.5.7"
  spec.add_dependency "asciimath"
  spec.add_dependency "htmlentities", "~> 4.3.4"
  spec.add_dependency "image_size"
  spec.add_dependency "mime-types"
  spec.add_dependency "nokogiri"
  spec.add_dependency "ruby-jing"
  spec.add_dependency "ruby-xslt"
  spec.add_dependency "thread_safe"
  spec.add_dependency "uuidtools"
  spec.add_dependency "asciidoctor-iso", ">= 0.7.5"
  spec.add_dependency "isodoc"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "equivalent-xml", "~> 0.6"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.6"
  spec.add_development_dependency "rubocop", "~> 0.50"
  spec.add_development_dependency "simplecov", "~> 0.15"
  spec.add_development_dependency "timecop", "~> 0.9"
end
