require "metanorma/generic"
require "asciidoctor"
require "metanorma/generic/converter"
require "isodoc/generic"

if defined? Metanorma
  Metanorma::Registry.instance.register(Metanorma::Generic::Processor)
end
