# frozen_string_literal: true

require "metanorma/generic/document"
require "metanorma/document/components/inline/fmt_ladl_label_data"
require_relative "model_tree"
require_relative "display"

module Metanorma
  module Generic
    module Presentation
      # Native presentation for labelled clauses and ordinary content.
      # Numbering belongs to the supplied LADL processor, never this stage.
      class Transformer
        class UnsupportedContent < ArgumentError; end

        # These need native adapters beyond heading/caption/xref projection. Do
        # not let a presentation marker silently advertise their conversion.
        UNSUPPORTED = %i[bibliography term terms definitions requirement recommendation permission
                         amend stem fn eref concept indexsect term_sources].freeze

        # LADL's adapter recognises the document root only for Metanorma::Document::Root
        # and the ISO root; without that the clause labellers never bind.
        # Teach it the Generic root here rather than patching the sibling gem.
        def self.ladl_adapter
          require "metanorma/ladl"
          require "metanorma/ladl/document_adapter"
          @ladl_adapter ||= Class.new(Metanorma::Ladl::DocumentAdapter) do
            private

            def root?(node)
              super || node.instance_of?(Metanorma::Generic::Document::Root)
            end
          end
        end

        def call(semantic_root, flavor:, options:)
          unless semantic_root.instance_of?(Metanorma::Generic::Document::Root)
            raise ArgumentError,
                  "Native generic presentation requires a Generic Root"
          end

          labeler = options[:document_labeler] || default_labeler
          unless labeler.respond_to?(:call)
            raise ArgumentError,
                  "Native generic presentation requires a callable document_labeler"
          end

          # Copy the Ruby object graph, including framework order/namespace state.
          # No document serialization, XML parser or temporary files are involved.
          root = Marshal.load(Marshal.dump(semantic_root))
          root.type = "presentation"
          tree = ModelTree.new(root)
          check_supported!(tree)
          tree.assign_ids!
          labelled = labeler.call(root, flavor: flavor, options: options)
          unless labelled.equal?(root)
            raise ArgumentError,
                  "document_labeler must return its supplied Generic Root"
          end

          Display.new(tree).apply
          root
        end

        private

        # The compile pipeline supplies a labeler only for ISO; generic and its
        # tastes number with the shared LADL ISO/IEC profile unless one is given.
        def default_labeler
          engine = Metanorma::Ladl::Engine.new(profile: Metanorma::Ladl::Profile.iso_iec)
          lambda do |model, **_context|
            engine.call(model,
                        adapter: Transformer.ladl_adapter.new(mode: :presentation))
          end
        end

        def check_supported!(tree)
          tree.nodes.each do |node|
            UNSUPPORTED.each do |key|
              next unless tree.value(node, key)
              next if Array(tree.value(node, key)).empty?

              raise UnsupportedContent,
                    "Native generic presentation does not yet support #{key}"
            end
          end
        end
      end
    end
  end
end
