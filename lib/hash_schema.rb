require "hash_schema/version"
require "hash_schema/error"
require "hash_schema/validator_factory"

class HashSchema
  class KeyNotDefinedError < HashSchema::Error; end
  class InvalidSchemaError < HashSchema::Error; end
  class NotAHashError < HashSchema::Error; end

  def initialize(schema_hash)
    @validators = generate_validators(schema_hash)
    # @schema_hash = schema_hash
  end

  def valid?(hash)
    valid_key?([], hash)
  end

  def valid_key?(key_path, value)
    target = traverse_validators(key_path)

    if target.is_a?(Hash)
      value.keys.size <= target.keys.size &&
        target.all? { |k, _| valid_key?(key_path + [k], value[k]) }
    else # it's a validator
      target.call(value)
    end
  end

  def subschema(key_path)
    subvalidators = traverse_validators(key_path)
    raise NotAHashError unless subvalidators.is_a?(Hash)

    # Schema can be initialized purely from validators.
    # Factory will just inject them without change
    HashSchema.new(subvalidators)
  end

  private

  attr_reader :validators

  def generate_validators(hash, path = [])
    factory = ValidatorFactory.new

    hash.map do |key, value|
      if value.is_a?(Hash)
        [key, generate_validators(value, path + [key])]
      else
        begin
          [key, factory.build(value)]
        rescue ValidatorFactory::InvalidBlueprintError
          raise InvalidSchemaError, (path + [key]).join('.')
        end
      end
    end.to_h
  end

  def traverse_validators(key_path)
    key_path.reduce(validators) do |acc, key|
      raise KeyNotDefinedError unless acc.is_a?(Hash) && acc.key?(key)

      acc[key]
    end
  end
  # Your code goes here...
end
