# frozen_string_literal: true

require "lutaml/model"

module Metanorma
  module Generic
    class Committee < Lutaml::Model::Serializable
      attribute :code, :string
      attribute :full_name, :string

      def display_name
        full_name || code
      end
    end
  end
end
