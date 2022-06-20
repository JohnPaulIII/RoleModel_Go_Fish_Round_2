require 'game'
require_relative 'spec_constants'
include Constants  

describe 'FishGame' do 

  attr_accessor :game

  it 'initalizes without arguments' do 
    @game = FishGame.new
    expect(game.players).to eq []
    expect(game.deck.card_count).to eq 52
  end

  it 'initializes all arguments' do 
    @game = FishGame.new(player_names: Constants::PLAYER_NAMES, deck: CardDeck.new(deck: [card('A', 'Spades')]))
    expect(game.players[0].name).to eq 'Josh'
    expect(game.players[1].name).to eq 'Will'
    expect(game.players[2].name).to eq 'Braden'
    game.players.each_index {|i| expect(game.players[i].name).to eq PLAYER_NAMES[i]}
    expect(game.deck.deck).to eq [card('A', 'Spades')]
    expect(game.current_player.name).to eq PLAYER_NAMES[game.current_player_index]
  end

  it 'game start deals cards' do 
    @game = FishGame.new(player_names: Constants::PLAYER_NAMES)
    game.start 
    game.players.each { |p| expect(p.hand.count) == FishGame::STARTING_HAND_COUNT}
  end

  describe '#play_round:' do

    before(:each) do
      @game = FishGame.new(player_names: Constants::PLAYER_NAMES[0,2], deck: CardDeck.new(deck: []))
    end

    it 'The player asks for a card, and gets it' do
      setup_rig_game(player_cards: [[card('A', 'Clubs')], [card('A', 'Spades')]])
      game.play_round('A', PLAYER_NAMES[game.first_player_index ^ 1])
      expected_round_results(player1_ending_hand: [card('A', 'Clubs'), card('A', 'Spades')])
    end

    it 'The player asks for a card, doesn\'t get it, and gets an identical rank from the deck' do
      setup_rig_game(player_cards: [[card('A', 'Clubs')], [card('2', 'Spades')]], deck: [card('A', 'Spades')])
      game.play_round('A', PLAYER_NAMES[game.first_player_index ^ 1])
      expected_round_results(player1_ending_hand: [card('A', 'Clubs'), card('A', 'Spades')], player2_ending_hand: [card('2', 'Spades')])
    end

    it 'The player asks for a card, doesn\'t get it, and doesn\'t get an identical rank from the deck' do
      setup_rig_game(player_cards: [[card('A', 'Clubs')], [card('2', 'Spades')]], deck: [card('3', 'Spades')])
      game.play_round('A', PLAYER_NAMES[game.first_player_index ^ 1])
      expected_round_results(player1_ending_hand: [card('A', 'Clubs'), card('3', 'Spades')], player2_ending_hand: [card('2', 'Spades')], ending_player_turn: 1)
    end

    it 'The player starts his turn with no cards, and the deck still has cards' do
      setup_rig_game(deck: [card('A', 'Clubs')])
      game.round_precheck
      expected_after_round_precheck(player1_ending_hand: [card('A', 'Clubs')])
    end

    it 'The player starts his turn with no cards, and the deck is empty' do
      setup_rig_game(player_cards: [[], [card('A', 'Clubs')]])
      game.round_precheck
      expected_after_round_precheck(player2_ending_hand: [card('A', 'Clubs')], ending_player_turn: 1)
    end

    it 'The player completes a book while receiving cards' do
      setup_rig_game(player_cards: [[card('A', 'Clubs'), card('A', 'Diamonds'), card('A', 'Hearts'), card('2', 'Clubs')], [card('A', 'Spades')]])
      game.play_round('A', PLAYER_NAMES[game.first_player_index ^ 1])
      expected_round_results(player1_ending_hand: [card('2', 'Clubs')], player1_ending_books: ['A'] )
    end
    
    it 'The game finishes after a single round' do
      setup_rig_game(player_cards: [[card('A', 'Clubs'), card('A', 'Diamonds'), card('A', 'Hearts')], [card('A', 'Spades')]], player_books: [%w( 2 3 4 5 6 7 8 9 10 J Q K ), []])
      expect(game.over?)
      game.play_round('A', PLAYER_NAMES[game.first_player_index ^ 1])
      expected_round_results(player1_ending_books: %w( 2 3 4 5 6 7 8 9 10 J Q K A ) )
      expect(game.over?).to be true
    end
    
  end

  def new_game(player_names: Constants::PLAYER_NAMES, deck: CardDeck.new)
    FishGame.new(player_names: player_names, deck: deck)
  end

  def setup_rig_game(player_cards: [[], []], player_books: [[], []], deck: [])
    game.players.each_with_index do |player, i|
      player.hand = player_cards[i]
      player.books = player_books[i]
    end
    game.deck = CardDeck.new(deck: deck)
    game.first_player_index = 0
  end

  def expected_round_results(player1_ending_hand: [], player2_ending_hand: [], player1_ending_books: [], ending_player_turn: 0)
    expect(game.players[0].hand).to eq player1_ending_hand
    expect(game.players[0].books).to eq player1_ending_books
    expect(game.players[1].hand).to eq player2_ending_hand
    expect(game.current_player_index).to eq ending_player_turn
    expect(game.deck.card_count).to eq 0
  end

  def expected_after_round_precheck(player1_ending_hand: [], player2_ending_hand: [], ending_player_turn: 0)
    expect(game.players[0].hand).to eq player1_ending_hand
    expect(game.players[1].hand).to eq player2_ending_hand
    expect(game.current_player_index).to eq ending_player_turn
  end
  
  def card(rank, suit)
    PlayingCard.new(rank, suit)
  end
end