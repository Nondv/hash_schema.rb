require 'set'

require 'hash_schema/validators/hash_validator'
require 'hash_schema/validators/abstract_validator'

class HashSchema
  class ValidatorFactory
    class InvalidBlueprintError < HashSchema::Error; end

    def build(blueprint)
      case blueprint
      when Proc, HashSchema::Validators::AbstractValidator
        blueprint
      when Class
        ->(x) { x.is_a?(blueprint) }
      when Set
        inner_validators = blueprint.map { |b| build(b) }
        ->(x) { inner_validators.any? { |v| v.call(x) } }
      when Array
        array_validator(blueprint)
      when Hash
        HashSchema::Validators::HashValidator.new(blueprint)
      else
        raise InvalidBlueprintError
      end
    end

    private

    def array_validator(blueprint)
      raise InvalidBlueprintError unless blueprint.is_a?(Array) && blueprint.size == 1

      element_validator = build(blueprint[0])
      ->(x) { x.is_a?(Array) && x.all?(&element_validator) }
    end
  end
end
