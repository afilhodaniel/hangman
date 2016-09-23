class WordRaffler
  def initialize(words =  %w(hi mom game fruit))
    @words = words
  end

  def raffle(word_length)
    @words.detect {|word| word.length == word_length}
  end
end