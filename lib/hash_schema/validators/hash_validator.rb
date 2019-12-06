require_relative 'abstract_validator'

class HashSchema
  module Validators
    class HashValidator < AbstractValidator
      class KeyDoesntExistError < HashSchema::Error; end

      def initialize(blueprint)
        factory = HashSchema::ValidatorFactory.new
        @validators = blueprint.map { |k, bp| [k, factory.build(bp)] }.to_h
      end

      def call(value)
        return false unless value.is_a?(Hash) &&
                            (value.keys - validators.keys).empty?

        validators.each { |k, v| return false unless v.call(value[k]) }
        true
      end

      private

      attr_reader :validators
    end
  end
end
