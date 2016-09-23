require 'spec_helper'
require 'game'

describe Game do
  let(:word_raffler) { double("word_raffler").as_null_object }

  subject(:game) { Game.new(word_raffler) }

  it "when just created" do
    expect(game.state).to eq(:initial)
  end

  describe "#ended?" do
    it "returns false when the game just started" do
      expect(game.state).to eq(:initial)
    end
  end

  describe "#player_won?" do
    before { 
      game.state = :word_raffled
      game.raffled_word = "hi"
    }

    it "returns true when the player guessed all letters with success" do
      game.guess_letter("h")
      game.guess_letter("i")

      game.player_won?.should be_truthy
    end

    it "returns false when the player didn't guessed all leters" do
      6.times { game.guess_letter("z") }

      game.player_won?.should be_falsy
    end

    it "returns false when the game is not in the :ended state" do
      game.state = :initial
      game.player_won?.should be_falsy

      game.state = :word_raffled
      game.player_won?.should be_falsy
    end
  end

  describe "#missed_parts" do
    it "returns an empty array when there's no missed parts" do
      game.missed_parts.should eq([])
    end

    it "returns the missed parts for each fail in guessing a letter" do
      game.raffled_word = "hey"

      3.times do
        game.guess_letter("z")
      end

      game.missed_parts.should eq(["head", "body", "left arm"])
    end
  end

  describe "#guess_letter" do
    before { game.raffled_word = "hey" }

    it "returns true if the raffled word contains the given letter" do
      game.guess_letter("h").should be_truthy
    end

    it "returns false if the raffled word doesn't contain the given letter" do
      game.guess_letter("z").should be_falsy
    end

    it "returns false if the given letter is a blank string" do
      game.guess_letter("").should be_falsy
      game.guess_letter(" ").should be_falsy
    end

    it "saves the guessed letter when the guess is right" do
      expect {
        game.guess_letter("h")
      }.to change {
        game.guessed_letters
      }.from([]).to(["h"])
    end

    it "does not save a guessed letter more than once" do
      game.guess_letter("h")

      expect {
        game.guess_letter("h")
      }.to_not change {
        game.guessed_letters
      }.from(["h"])
    end

    it "makes a transition to the :ended state when all the letters are guessed with success" do
      game.state = :word_raffled
      game.raffled_word = "hi"

      expect {
        game.guess_letter("h")
        game.guess_letter("i")
      }.to change {
        game.state
      }.from(:word_raffled).to(:ended)
    end

    it "makes a transition to the :ended state when the player miss 6 times trying to guess a letter" do
      game.state = :word_raffled
      game.raffled_word = "hi"

      expect {
        6.times { game.guess_letter("z") }
      }.to change {
        game.state
      }.from(:word_raffled).to(:ended)
    end
  end

  describe "#guessed_letters" do
    it "returns the guessed letters" do
      game.raffled_word = "hey"
      game.guess_letter("e")

      game.guessed_letters.should eq(["e"])
    end

    it "returns an empty array when there's no guessed letters" do
      game.guessed_letters.should eq([])
    end
  end

  describe "#raffle" do
    it "raffles a word with the given length" do
      word_raffler.should_receive(:raffle).with(3)

      expect {
        game.raffle(3)
      }.to change {
        game.state
      }.from(:initial).to(:word_raffled)
    end

    it "saves the raffled word" do
      raffled_word = "mom"
      word_raffler.stub(raffle: raffled_word)

      game.raffle(3)

      game.raffled_word.should eq(raffled_word)
    end

    it "stays on the :initial state when a word can't be raffled" do
      word_raffler.stub(raffle: nil)

      game.raffle(3)

      expect(game.state).to eq(:initial)
    end
  end

  describe "#finish" do
    it "sets the game as ended" do
      game.finish

      expect(game.state).to eq(:ended)
    end
  end
end