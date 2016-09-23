require 'spec_helper'
require 'game_flow'

describe GameFlow do
  let(:ui) { double("ui").as_null_object }
  let(:game) { double("game", state: :initial, guessed_letters: []).as_null_object }

  subject(:game_flow) { GameFlow.new(game, ui) }

  describe "#start" do
    it "prints the initial message" do
      ui.should_receive(:write).with("Welcome to the hangman game")

      game_flow.start
    end
  end

  describe "next_step" do
    context "when the game is in the :initial state" do
      it "asks the player for the length of the word to be raffled" do
        ui.should_receive(:write).with("Wich size of the word to be drawn?")

        ui.should_receive(:read).and_return("3")

        game_flow.next_step
      end

      context "and the player asks to raffle a word" do
        it "raffles a word with the given length" do
          word_length = "3"
          ui.stub(read: word_length)

          game.should_receive(:raffle).with(word_length.to_i)

          game_flow.next_step
        end

        it "prints a '_' for each letter in the raffled word" do
          word_length = "3"
          ui.stub(read: word_length)
          game.stub(raffle: "mom", raffled_word: "mom")

          ui.should_receive(:write).with("___")

          game_flow.next_step
        end

        it "tells if it's not possible to raffle with the given length" do
          word_length = "20"
          ui.stub(read: word_length)
          game.stub(raffle: nil)

          ui.should_receive(:write).with("We don't have any word with this number of letters")

          game_flow.next_step
        end
      end
    end

    context "when the game is in the :word_raffled state" do
      before { game.stub(state: :word_raffled) }
      
      it "asks the player to guess a letter" do
        ui.should_receive(:write).with("Which letter do you think the word is?")

        game_flow.next_step
      end

      context "and the player guess a letter with success" do
        before { game.stub(guess_letter: true) }

        it "prints a success message" do
          ui.should_receive(:write).with("You guessed a successful letter")

          game_flow.next_step
        end

        it "prints the guesses letters" do
          game.stub(raffled_word: "hey", guessed_letters: ["e"])

          ui.should_receive(:write).with("_e_")

          game_flow.next_step
        end
      end

      context "and the player fails to guess a letter" do
        before { game.stub(guess_letter: false) }

        it "prints a error message" do
          ui.should_receive(:write).with("You missed the letter")

          game_flow.next_step
        end

        it "prints the list of the missed parts" do
          game.stub(missed_parts: ["head"])
          
          ui.should_receive(:write).with("You lost parts: head")

          game_flow.next_step
        end
      end
    end

    context "when the game is in the :ended state" do
      before { game.stub(state: :ended) }

      it "prints a success message when the player win" do
        game.stub(player_won?: true)

        ui.should_receive(:write).with("You win")

        game_flow.next_step
      end

      it "prints a defeat message when the player lose" do
        game.stub(player_won?: false)

        ui.should_receive(:write).with("You lose")

        game_flow.next_step
      end
    end

    it "finishes the game when the player asks to" do
      player_input = "end"
      ui.stub(read: player_input)

      game.stub(state: :initial)
      game.should_receive(:finish)
      game_flow.next_step

      game.stub(state: :word_raffled)
      game.should_receive(:finish)
      game_flow.next_step
    end
  end
end