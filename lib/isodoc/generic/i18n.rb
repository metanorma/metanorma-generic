require_relative "utils"

module IsoDoc
  module Generic
    class I18n < IsoDoc::I18n
      def load_yaml1(lang, script)
        return super unless configuration.i18nyaml
        file = configuration.i18nyaml.is_a?(Hash) ?
          configuration.i18nyaml[lang] : configuration.i18nyaml
        return super if file.nil?
        y = YAML.load_file(baselocation(file))
        super.merge(y)
      end

      include Utils
    end
  end
end
