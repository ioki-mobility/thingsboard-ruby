module Dummys
end

module DummyClassHelpers

  def dummy_class(name, superclass = Object, &block)
    let(name.to_s.underscore) do
      klass = Class.new(superclass, &block)

      Dummys.const_set (name.to_s + SecureRandom.hex(5)).classify, klass
    end
  end
end

RSpec.configure do |c|
  c.extend DummyClassHelpers
end
