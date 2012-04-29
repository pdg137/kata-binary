# -*- coding: utf-8 -*-
require_relative 'spec_helper'
require 'my_kata'

describe Utf8Parser, "#display_byte_in_binary" do
  it 'should display bytes as binary' do
    Utf8Parser.display_byte_in_binary(123).should == "01111011"
  end 
end

describe Utf8Parser, "#display_bytes_in_binary" do
  it 'should display strings as binary' do
    Utf8Parser.display_bytes_in_binary("abcdé").should == "01100001 01100010 01100011 01100100 11000011 10101001"
    Utf8Parser.display_bytes_in_binary("你好").should == "11100100 10111101 10100000 11100101 10100101 10111101"
  end
end

describe Utf8Parser, "#is_ascii?" do
  context "given bytes < 128" do
    it "should return true" do
      (0..127).each do |i|
        Utf8Parser.is_ascii?(i).should == true
      end
    end
  end
  context "given bytes >= 128" do
    it "should return false" do
      (128..255).each do |i|
        Utf8Parser.is_ascii?(i).should == false
      end
    end
  end
end

describe Utf8Parser, "#is_continuation_character?" do
  context "given various continuations" do
    it "should return true" do
      Utf8Parser.is_continuation_character?(0b10000000).should == true
      Utf8Parser.is_continuation_character?(0b10000001).should == true
      Utf8Parser.is_continuation_character?(0b10110000).should == true
      Utf8Parser.is_continuation_character?(0b10111111).should == true
    end
  end
  context "given various non-continuations" do
    it "should return false" do
      Utf8Parser.is_continuation_character?(0b00000000).should == false
      Utf8Parser.is_continuation_character?(0b11000000).should == false
      Utf8Parser.is_continuation_character?(0b11100000).should == false
      Utf8Parser.is_continuation_character?(0b11111111).should == false
    end
  end
end

describe Utf8Parser, "#is_two_byte_start?" do
  context "give two-byte start" do
    it "should return true" do
      Utf8Parser.is_two_byte_start?(0b11000001).should == true
      Utf8Parser.is_two_byte_start?(0b11011111).should == true
    end
  end
  context "give non-two-byte start" do
    it "should return false" do
      Utf8Parser.is_two_byte_start?(0b11100001).should == false
      Utf8Parser.is_two_byte_start?(0b00011111).should == false
    end
  end
end

describe Utf8Parser, "#new" do
  context "given abcdé" do
    let(:parser) { Utf8Parser.new "abcdé" }
    it 'should return an enumerable for 5 characters' do
      parser.should be_kind_of(Enumerable)
      parser.count.should == 5
      parser.to_a[0].should == 0x61
      parser.to_a[1].should == 0x62
      parser.to_a[2].should == 0x63
      parser.to_a[3].should == 0x64
      parser.to_a[4].should == 0xe9
    end
  end

  context "given 你好" do
    let(:parser) { Utf8Parser.new "你好" }
    it 'should return an enumerable for 2 characters' do
      parser.should be_kind_of(Enumerable)
      parser.count.should == 2
      parser.to_a[0].should == 20320
      parser.to_a[1].should == 22909
    end
  end
end
