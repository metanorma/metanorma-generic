# frozen_string_literal: true

# Forward-declare parent namespace so this file is safe to require
# directly (without first requiring metanorma/generic.rb). Re-opening
# an existing module is idempotent.
module Metanorma
  module Generic
  end
end

module Metanorma
  module Generic::Document
    autoload :Root, "metanorma/generic/document/root"
  end
end

# Backwards-compat alias so external consumers that reference
# Metanorma::GenericDocument keep resolving during the transition.
# Silently overrides any prior constant (older metanorma-document
# releases shipped their own copy) to avoid Ruby's "already initialized
# constant" warning. Scheduled for removal once downstream consumers
# migrate.
module Metanorma
  existing = defined?(Metanorma::GenericDocument) && Metanorma::GenericDocument
  if !existing.equal?(Metanorma::Generic::Document)
    Metanorma.send(:remove_const, :GenericDocument) if existing
    GenericDocument = Metanorma::Generic::Document
  end
end

if defined?(Metanorma::Registers::Setup.setup_generic_register)
  Metanorma::Registers::Setup.setup_generic_register
end

# Mark alias as deprecated AFTER setup so the register's own reference
# doesn't trip the warning.
module Metanorma
  deprecate_constant :GenericDocument
end
