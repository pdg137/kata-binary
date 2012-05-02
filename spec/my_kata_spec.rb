# -*- coding: utf-8 -*-
require_relative 'spec_helper'
require 'my_kata'

describe Utf8Parser, "byte_type" do
  it "should return :ascii for ASCII bytes" do
    (0..127).each do |x|
      Utf8Parser.byte_type(x).should == :ascii
    end
  end
  it "should return :two_byte_start for bytes like 110xxxxx" do
    [0b11000000, 0b11011111, 0b11010101].each do |x|
      Utf8Parser.byte_type(x).should == :two_byte_start
    end
  end
  it "should return :three_byte_start for bytes like 1110xxxx" do
    [0b11100000, 0b11101111, 0b11100101].each do |x|
      Utf8Parser.byte_type(x).should == :three_byte_start
    end
  end
  it "should return :continuation for bytes like 10xxxxxx" do
    [0b10000000, 0b10011111, 0b10110101].each do |x|
      Utf8Parser.byte_type(x).should == :continuation
    end
  end
end

describe Utf8Parser do
  context "given an ascii string" do
    let(:parser) { Utf8Parser.new "abcd" }
    it "should be an Enumerable" do
      parser.should be_a_kind_of Enumerable
    end
    it "should return the right characters" do
      parser.to_a.should == [97, 98, 99, 100]
    end
  end

  context "given a more complicated string" do
    let(:parser) { Utf8Parser.new "abcdé" }
    it "should be an Enumerable" do
      parser.should be_a_kind_of Enumerable
    end
    it "should return the right characters" do
      parser.to_a.should == [97, 98, 99, 100, 233]
    end
  end

  context "given a more complicated string" do
    let(:parser) { Utf8Parser.new "abcdé你好" }
    it "should be an Enumerable" do
      parser.should be_a_kind_of Enumerable
    end
    it "should return the right characters" do
      parser.to_a.should == [97, 98, 99, 100, 233, 20320, 22909]
    end
  end
end
