require "metanorma/generic"
require "asciidoctor"
require "metanorma/generic/converter"
require "isodoc/generic"
require "metanorma"

if defined? Metanorma::Registry
  Metanorma::Registry.instance.register(Metanorma::Generic::Processor)
end
