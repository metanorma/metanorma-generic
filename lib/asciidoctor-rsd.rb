require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/rsd/converter"
require_relative "isodoc/rsd/rsdhtmlconvert"
require_relative "isodoc/rsd/rsdwordconvert"
require_relative "asciidoctor/rsd/version"

if defined? Metanorma
  require_relative "metanorma/rsd"
  Metanorma::Registry.instance.register(Metanorma::Rsd::Processor)
end
