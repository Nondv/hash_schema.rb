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

  it 'raises exception when something irregular provided' do
    error_class = described_class::InvalidSchemaError

    expect { init(obj: Object.new) }.to raise_error(error_class)
    expect { init(key: :int) }.to raise_error(error_class)
  end


  describe 'basic functionality' do
    it "is a bit weird for booleans since there's no Bool class in Ruby" do
      schema = init(b: Set[TrueClass, FalseClass])
      expect(schema.valid?(b: true)).to be true
      expect(schema.valid?(b: false)).to be true

      expect(schema.valid?({})).to be false
      expect(schema.valid?(b: nil)).to be false
      expect(schema.valid?(b: Object.new)).to be false
    end

    it 'works with arrays' do
      schema = init(x: [Integer])
      expect(schema.valid?(x: 123)).to be false
      expect(schema.valid?(x: [123])).to be true
      expect(schema.valid?(x: [123.0])).to be false
      expect(schema.valid?(x: [])).to be true
      expect(schema.valid?(x: (1..1000).to_a)).to be true
    end

    it 'works with complicated arrays' do
      multiclass = init(x: [Set[Integer, String]])
      expect(multiclass.valid?(x: [1, 2, 3])).to be true
      expect(multiclass.valid?(x: %w[1 2 3])).to be true
      expect(multiclass.valid?(x: [1, '2', 3])).to be true

      arrays = init(x: [[Integer]])
      expect(arrays.valid?(x: [1, 2, 3])).to be false
      expect(arrays.valid?(x: [[1, 2, 3]])).to be true
      expect(arrays.valid?(x: [[1], [2], [3]])).to be true

      hashes = init(x: [{ x: Integer, y: Set[NilClass, String] }])
      expect(hashes.valid?(x: [])).to be true
      expect(hashes.valid?(x: [{}])).to be false
      expect(hashes.valid?(x: [{ x: 1 }])).to be true
      expect(hashes.valid?(x: [{ x: 1, y: '1' }])).to be true
    end

    it 'works with sets' do
      schema = init(x: Set[NilClass, Integer, String])
      expect(schema.valid?(x: 123)).to be true
      expect(schema.valid?(x: '123')).to be true
      expect(schema.valid?(x: nil)).to be true
      expect(schema.valid?({})).to be true

      expect(schema.valid?(x: :abc)).to be false
      expect(schema.valid?(x: Set[NilClass, Integer, String])).to be false
    end

    it 'works with complicated Sets' do
      schema = init(x: Set[NilClass, { a: Integer }, [Integer]])

      expect(schema.valid?({})).to be true
      expect(schema.valid?(x: nil)).to be true
      expect(schema.valid?(y: nil)).to be false

      expect(schema.valid?(x: [1, 2, 3])).to be true
      expect(schema.valid?(x: %w[1 2 3])).to be false
      expect(schema.valid?(x: [])).to be true

      expect(schema.valid?(x: { a: 123 })).to be true
      expect(schema.valid?(x: { a: '123' })).to be false
      expect(schema.valid?(x: { a: 123, b: nil })).to be false
      expect(schema.valid?(x: { a: nil })).to be false
    end
  end
end
