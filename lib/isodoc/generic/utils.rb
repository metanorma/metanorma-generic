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
        return nil if loc.nil? || loc.empty?
        f = defined?(self.class::_file) ? (self.class::_file || __FILE__) :
          __FILE__
        File.expand_path(File.join(
          File.dirname(f), "..", "..", "..", loc))
      end
    end
  end
end
