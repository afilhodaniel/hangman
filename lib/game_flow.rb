require_relative 'cli_ui'
require_relative 'game'

require 'forwardable'

class GameFlow
  extend Forwardable
  delegate :ended? => :@game
  
  def initialize(game = Game.new, ui = CliUi.new)
    @game = game
    @ui = ui
  end

  def start
    @ui.write "Welcome to the hangman game"
  end

  def next_step
    case @game.state
    when :initial
      ask_to_raffle_a_word
    when :word_raffled
      ask_to_guess_a_letter
    end

    print_game_final_result if @game.ended?
  end

  private

    def print_game_final_result
      if @game.player_won?
        @ui.write "You win"
      else
        @ui.write "You lose"
      end
    end

    def ask_to_raffle_a_word
      ask_the_player("Wich size of the word to be drawn?") do |length|
        if @game.raffle(length.to_i)
          @ui.write guessed_letters
        else
          @ui.write "We don't have any word with this number of letters"
        end
      end
    end

    def ask_to_guess_a_letter
      ask_the_player("Which letter do you think the word is?") do |letter|
        if @game.guess_letter(letter)
          @ui.write "You guessed a successful letter"
          @ui.write guessed_letters
        else
          @ui. write "You missed the letter"
          @ui.write "You lost parts: #{@game.missed_parts.join(', ')}"
        end
      end
    end

    def ask_the_player(question)
      @ui.write(question)
      player_input = @ui.read.strip

      if player_input == "end"
        @game.finish
      else
        yield player_input.strip
      end
    end
    
    def guessed_letters
      letters = ""

      @game.raffled_word.each_char do |letter|
        if @game.guessed_letters.include?(letter)
          letters += letter
        else
          letters += "_"
        end
      end

      letters
    end

    def print_letters_feedback
      letters_feedback = ""

      @game.raffled_word.length.times do
        letters_feedback << "_"
      end

      letters_feedback.strip!

      @ui.write(letters_feedback)
    end

end