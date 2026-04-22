require "metanorma/generic"
require "asciidoctor"
require "metanorma/generic/converter"
require "metanorma/generic/validate"
require "metanorma/generic/cleanup"
require "isodoc/generic"
require "metanorma-core"

if defined? Metanorma::Registry
  Metanorma::Registry.instance.register(Metanorma::Generic::Processor)
end
