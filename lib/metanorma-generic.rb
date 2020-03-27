require "metanorma/acme"
require "asciidoctor"
require "asciidoctor/acme"
require "isodoc/acme"

if defined? Metanorma
  Metanorma::Registry.instance.register(Metanorma::Acme::Processor)
end
