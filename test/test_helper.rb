require 'logginator'
require 'minitest/autorun'
require 'mocha/mini_test'


class MockIO

  def initialize(lines = [])
    @lines = lines
  end


  def each
    while(!@lines.empty?) do
      yield(@lines.shift)
    end
    loop {}
  end

end

