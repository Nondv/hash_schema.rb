require 'spec_helper'
require 'hash_schema'

RSpec.describe HashSchema do
  def init(*args)
    described_class.new(*args)
  end

  it 'uses classes, sets, arrays and hashes for definiton' do
    init(
      int: Integer,
      maybe_int: Set[Integer, NilClass],
      bool: Set[TrueClass, FalseClass],
      array_int: [Integer],
      maybe_array_int: Set[[Integer], NilClass]
    )
  end

  it "is a bit weird for booleans since there's no Bool class in Ruby" do
    schema = init(b: Set[TrueClass, FalseClass])
    expect(schema.valid_key?([:b], true)).to be true
    expect(schema.valid_key?([:b], false)).to be true

    expect(schema.valid_key?([:b], nil)).to be false
    expect(schema.valid_key?([:b], Object.new)).to be false
  end

  it 'raises exception when something irregular provided' do
    error_class = described_class::InvalidSchemaError

    expect { init(obj: Object.new) }.to raise_error(error_class)
    expect { init(key: :int) }.to raise_error(error_class)
  end

  describe '#valid_key?' do
    it 'is the main method to check validity of an object' do
      schema = init(x: Integer, y: Set[String, NilClass])

      expect(schema.valid_key?([:x], 123)).to be true
      expect(schema.valid_key?([:x], nil)).to be false
      expect(schema.valid_key?([:y], nil)).to be true
    end

    it 'can access nested hashes' do
      schema = init(x: { y: { z: Set[TrueClass, FalseClass] } })

      expect(schema.valid_key?([:x, :y, :z], false)).to be true
      expect(schema.valid_key?([:x, :y, :z], nil)).to be false
    end

    it 'raises error when accessing key not in schema' do
      error_class = described_class::KeyNotDefinedError

      schema = init(x: { y: { z: Set[TrueClass, FalseClass] } })
      expect { schema.valid_key?([:y], 1) }.to raise_error(error_class)
      expect { schema.valid_key?([:x, :z], 1) }.to raise_error(error_class)
      expect { schema.valid_key?([:x, :z], 1) }.to raise_error(error_class)

      expect(schema.valid_key?([:x,:y, :z], true)).to be true
      expect { schema.valid_key?([:x,:y, :z, :a], 1) }.to raise_error(error_class)
    end
  end

  describe '#subschema' do
    it 'returns subset of schema by key path' do
      schema = init(x: { y: { z: Set[TrueClass, FalseClass] } })
      x_sub = schema.subschema([:x])

      expect(x_sub.valid_key?([], y: { z: false })).to be true
      expect(x_sub.valid_key?([:y], z: false)).to be true

      y_sub = x_sub.subschema([:y])
      expect(y_sub.valid_key?([], z: false)).to be true
      expect(y_sub.valid_key?([:z], false)).to be true

      expect(schema.subschema([:x, :y]).valid_key?([:z], false)).to be true
      expect { schema.subschema([:x, :y, :z]) }.to raise_error(described_class::NotAHashError)
    end
  end
end
