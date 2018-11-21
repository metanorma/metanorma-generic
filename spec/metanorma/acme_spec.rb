require "spec_helper"

RSpec.describe Metanorma::Acme do
  it "has a version number" do
    expect(Metanorma::Acme::VERSION).not_to be nil
  end
end
