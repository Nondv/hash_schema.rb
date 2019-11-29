require 'hash_schema/error'
require 'hash_schema/validator_factory'

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

    def nested(&block)
      raise NoBlockGivenError unless block_given?

      {}.tap(&block)
    end

    def number
      Numeric
    end

    def bool
      Set[TrueClass, FalseClass]
    end
  end
end
