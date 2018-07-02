require "asciidoctor" unless defined? Asciidoctor::Converter
require_relative "asciidoctor/sample/converter"
require_relative "isodoc/sample/rsdhtmlconvert"
require_relative "isodoc/sample/rsdwordconvert"
require_relative "asciidoctor/sample/version"

if defined? Metanorma
  require_relative "metanorma/sample"
  Metanorma::Registry.instance.register(Metanorma::Sample::Processor)
end
