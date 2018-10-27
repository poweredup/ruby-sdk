module TurboPlay
  class MintedToken < Base
    attributes :id, :symbol, :subunit_to_unit, :name, :metadata, :encrypted_metadata
  end
end
