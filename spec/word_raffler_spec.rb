require 'spec_helper'
require 'word_raffler'

describe WordRaffler do
  it "raffles a word from a given list of words" do
    words = %w( me you nice )
    raffler = WordRaffler.new(words)

    raffler.raffle(2).should == "me"
    raffler.raffle(3).should == "you"
    raffler.raffle(4).should == "nice"
  end

  it "returns nil it doesn't have a word with the given length" do
    words = %w( me you nice )
    raffler = WordRaffler.new(words)

    raffler.raffle(20).should be_nil
  end
end