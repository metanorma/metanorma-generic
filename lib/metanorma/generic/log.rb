module Metanorma
  module Generic
    class Converter
      GENERIC_LOG_MESSAGES = {
        # rubocop:disable Naming/VariableNumber
        "GENERIC_1": { category: "Document Attributes",
                       error: "%s is not a legal document type: reverting to '%s'",
                       severity: 2 },
        "GENERIC_2": { category: "Document Attributes",
                       error: "%s is not a recognised status",
                       severity: 2 },
        "GENERIC_3": { category: "Document Attributes",
                       error: "%s is not a recognised committee",
                       severity: 2 },
      }.freeze
      # rubocop:enable Naming/VariableNumber

      def log_messages
        super.merge(GENERIC_LOG_MESSAGES)
      end
    end
  end
end
