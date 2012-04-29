module AmendableEnumerable
  include Enumerable

  def each
    @pending_value = nil
    each_with_amend do |value|
      if @pending_value
        yield @pending_value
      end
      @pending_value = value
    end
    if @pending_value
      yield @pending_value
    end
  end

  def amend
    @pending_value = yield @pending_value
  end
end

class Utf8Parser
  include AmendableEnumerable
  def self.display_byte_in_binary(b)
    place = 128
    s = ""
    while place > 0
      if b >= place
        s += "1"
        b -= place
      else
        s += "0"
      end
      place /= 2
    end
    s
  end

  def self.display_bytes_in_binary(s)
    s.bytes.collect do |b|
      display_byte_in_binary(b)
    end.join " "
  end

  def initialize(s)
    @utf8_string = s
  end

  def self.is_ascii?(b)
    return b & 0b10000000 == 0
  end

  def self.is_continuation_character?(b)
    return b & 0b11000000 == 0b10000000
  end

  def self.is_two_byte_start?(b)
    return b & 0b11100000 == 0b11000000
  end

  def self.is_three_byte_start?(b)
    return b & 0b11110000 == 0b11100000
  end

  def each_with_amend
    @utf8_string.bytes.each do |b|
      if Utf8Parser.is_continuation_character? b
        # continuation character - tack it on
        amend do |value|
          (value <<= 6) | (b & 0b00111111)
        end
      end

      if Utf8Parser.is_ascii? b
        # ascii character
        yield b
      elsif Utf8Parser.is_two_byte_start? b
        # start of a two-byte character
        yield b & 0b00011111
      elsif Utf8Parser.is_three_byte_start? b
        # start of a three-byte character
        yield b ^ 0b11100000
      end
    end
  end
end
