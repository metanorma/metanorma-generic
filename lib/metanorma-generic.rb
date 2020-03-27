require "metanorma/generic"
require "asciidoctor"
require "asciidoctor/generic"
require "isodoc/generic"

if defined? Metanorma
  Metanorma::Registry.instance.register(Metanorma::Generic::Processor)
end
