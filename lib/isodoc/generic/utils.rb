module IsoDoc
  module Generic
    module Utils
      def configuration
        Metanorma::Generic.configuration
      end

      def fileloc(loc)
        File.join(File.dirname(__FILE__), loc)
      end

      def baselocation(loc)
        loc.nil? and return nil
        loc.empty? and return ""
        loc
      end
    end
  end
end
