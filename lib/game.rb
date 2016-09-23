require_relative 'cli_ui'
require_relative 'word_raffler'

class Game
  attr_accessor :raffled_word, :state, :guessed_letters, :missed_parts

  HANGMAN_PARTS = ["head", "body", "left arm", "right arm", "left leg", "right leg"]

  def initialize(word_raffler = WordRaffler.new)
    @word_raffler = word_raffler
    @state = :initial
    @guessed_letters = []
    @missed_parts = []
    @wrong_guesses = 0
  end

  def player_won?
    return false if @state != :ended

    all_letters_were_guessed?
  end

  def guess_letter(letter)
    return false if letter.strip == ''

    if @raffled_word.include?(letter)
      @guessed_letters << letter
      @guessed_letters = @guessed_letters.uniq

      @state = :ended if all_letters_were_guessed?

      return true
    else
      @missed_parts << HANGMAN_PARTS[@wrong_guesses]
      @wrong_guesses += 1

      @state = :ended if @wrong_guesses == 6

      return false
    end
  end

  def raffle(word_length)
    if @raffled_word = @word_raffler.raffle(word_length)
      @state = :word_raffled
    end
  end

  def finish
    @state = :ended
  end

  def ended?
    if @state == :ended
      true
    else
      false
    end
  end

  private

    def all_letters_were_guessed?
      @guessed_letters.sort == @raffled_word.to_s.chars.to_a.uniq.sort
    end

end