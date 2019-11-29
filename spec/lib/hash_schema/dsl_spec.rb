require 'bigdecimal'

require 'spec_helper'
require 'hash_schema'
require 'hash_schema/dsl'

RSpec.describe HashSchema::DSL do
  it 'works' do
    schema = described_class.build_schema do |hash, dsl|
      hash[:some_int] = Integer
      hash[:maybe_int] = Set[Integer, NilClass]
      hash[:sub_hash] = { a: Set[String, NilClass],
                          b: { c: Integer } }
    end

    expect(schema.valid?(some_int: 1, sub_hash: { a: 'abc', b: { c: 123 } }))
  end

  it '#maybe' do
    schema = described_class.build_schema do |hash, dsl|
      hash[:int] = Integer
      hash[:maybe_int] = dsl.maybe(Integer)
    end

    expect(schema.valid?(int: 5)).to be true
    expect(schema.valid?(int: 5, maybe_int: nil)).to be true
    expect(schema.valid?(int: 5, maybe_int: 5)).to be true

    expect(schema.valid?(int: 5, maybe_int: '5')).to be false
    expect(schema.valid?(maybe_int: 5)).to be false
  end

  it '#nested' do
    schema = described_class.build_schema do |h, dsl|
      h[:id] = Integer
      h[:info] = dsl.nested do |info|
        info[:name] = String
        info[:contacts] = dsl.nested do |contacts|
          contacts[:phone] = String
          contacts[:address] = Set[NilClass, String]
        end
      end
      h[:spouse] = Set[NilClass, dsl.nested { |spouse| spouse[:name] = String }]
    end

    expect(
      schema.valid?(id: 1, info: { name: 'John', contacts: { phone: '123' } })
    ).to be true
    expect(
      schema.valid?(
        id: 1,
        info: { name: 'John', contacts: { phone: '123', address: 'asd' } }
      )
    ).to be true

    expect(schema.valid?(id: 1)).to be false
    expect(
      schema.valid?(
        id: 1,
        info: { name: 'John', contacts: { phone: '123', address: 'asd' } },
        spouse: { name: 'Jane' }
      )
    ).to be true
    expect(
      schema.valid?(id: 1, info: { name: 'John', contacts: { address: 'asd' } })
    ).to be false
    expect(
      schema.valid?(
        id: 1,
        info: { name: 'John', contacts: { phone: '1234' } },
        spouse: { last_name: 'Doe' }
      )
    ).to be false
  end

  it '#number' do
    schema = described_class.build_schema do |h, dsl|
      h[:x] = dsl.number
    end

    expect(schema.valid?(x: 1)).to be true
    expect(schema.valid?(x: 1.0)).to be true
    expect(schema.valid?(x: BigDecimal('123.45'))).to be true
    expect(schema.valid?(x: '1')).to be false
  end

  it '#bool' do
    schema = described_class.build_schema do |h, dsl|
      h[:x] = dsl.bool
    end

    expect(schema.valid?(x: true)).to be true
    expect(schema.valid?(x: false)).to be true
    expect(schema.valid?(x: 'true')).to be false
    expect(schema.valid?(x: nil)).to be false
    expect(schema.valid?({})).to be false
  end
end
