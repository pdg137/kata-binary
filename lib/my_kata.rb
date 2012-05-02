class Utf8Parser
  include Enumerable
  def self.byte_type(x)
    case
    when x & 0b10000000 == 0
      return :ascii
    when x & 0b11000000 == 0b10000000
      return :continuation
    when x & 0b11100000 == 0b11000000
      return :two_byte_start
    when x & 0b11110000 == 0b11100000
      return :three_byte_start
    end
  end

  def initialize(s)
    @s = s
  end

  def each
    groups = @s.each_byte.to_a.slice_before do |b|
      case Utf8Parser.byte_type b
      when :ascii, :two_byte_start, :three_byte_start
        true
      else
        false
      end
    end

    groups.each do |g|
      if g.length == 1
        yield g[0] # ascii
      else
        start = g.shift
        case Utf8Parser.byte_type start
        when :two_byte_start
          x = start & 0b00011111
        when :three_byte_start
          x = start & 0b00001111
        end
        
        while b = g.shift
          x <<= 6
          x |= (b & 0b00111111)
        end

        yield x
      end
    end
  end
end
