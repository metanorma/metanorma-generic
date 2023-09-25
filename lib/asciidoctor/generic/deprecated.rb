warn <<~WARN
  Please replace your references to Asciidoctor::Generic with Metanorma::Generic and your instances of require 'asciidoctor/generic' with require 'metanorma/generic'
WARN

exit 127 if ENV["METANORMA_DEPRECATION_FAIL"]

Asciidoctor::Generic = Metanorma::Generic unless defined? Asciidoctor::Generic
