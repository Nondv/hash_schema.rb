require_relative 'hash_validator'

class HashSchema
  module Validators
    # Use this when you don't care if there're extra keys set
    class HashSubsetValidator < AbstractValidator
      def initialize(blueprint)
        @keys = blueprint.keys
        @hash_validator = HashSchema::Validators::HashValidator.new(blueprint)
      end

      def call(value)
        return false unless value.is_a?(Hash)

        @hash_validator.call(value.slice(*keys))
      end

      private

      attr_reader :keys, :hash_validator
    end
  end
end
