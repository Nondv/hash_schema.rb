require 'hash_schema/error'
require 'hash_schema/validator_factory'
require 'hash_schema/validators/hash_subset_validator'

class HashSchema
  class DSL
    class NoBlockGivenError < HashSchema::Error; end

    def self.build_schema(&block)
      HashSchema.new(new(&block).result)
    end

    attr_reader :result

    def initialize
      raise NoBlockGivenError unless block_given?

      @result = {}
      yield(@result, self)
    end

    def maybe(blueprint)
      Set[blueprint, NilClass]
    end

    def nested(extra_keys_allowed: false, &block)
      raise NoBlockGivenError unless block_given?

      hash_blueprint = {}.tap(&block)

      if extra_keys_allowed
        HashSchema::Validators::HashSubsetValidator.new(hash_blueprint)
      else
        hash_blueprint
      end
    end

    def number
      Numeric
    end

    def bool
      Set[TrueClass, FalseClass]
    end
  end
end
