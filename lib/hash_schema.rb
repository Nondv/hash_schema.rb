require "hash_schema/version"
require "hash_schema/error"
require "hash_schema/validator_factory"

class HashSchema
  class KeyNotDefinedError < HashSchema::Error; end
  class InvalidSchemaError < HashSchema::Error; end
  class NotAHashError < HashSchema::Error; end

  def initialize(schema_hash)
    factory = ValidatorFactory.new
    @validator = factory.build(schema_hash)
  rescue ValidatorFactory::InvalidBlueprintError
    raise InvalidSchemaError
  end

  def valid?(hash)
    validator.call(hash)
  end

  private

  attr_reader :validator
  # Your code goes here...
end
