require 'game'
require 'socket'
require_relative 'spec_constants'
include Constants  

describe 'FishGame' do 

  attr_accessor :game, :server, :clients, :sockets, :broadcast

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

  it 'can reduce a player\'s hand to a simple string array' do
    @game = FishGame.new(player_names: Constants::PLAYER_NAMES)
    game.players[0].hand = [card('A', 'Clubs'), card('2', 'Spades'), card('10', 'Hearts'), card('J', 'Diamonds')]
    game.first_player_index = 0
    expect(game.get_abbreviated_player_cards).to eq %w( AC 2S 10H JD )
  end

  describe '#play_round:' do

    before(:each) do
      @server = TCPServer.new('localhost', Constants::TEST_PORT_NUMBER)
      @clients = (0..2).to_a.map { TCPSocket.new('localhost', Constants::TEST_PORT_NUMBER) }
      @sockets = (0..2).to_a.map { server.accept }
      @broadcast = Broadcaster.new(names: Constants::PLAYER_NAMES, sockets: sockets)
      @game = FishGame.new(player_names: Constants::PLAYER_NAMES[0,2], deck: CardDeck.new(deck: []), broadcast: broadcast)
    end

    after(:each) do
      server.close
      clients.each { |client| client.close }
    end

    it 'The player asks for a card, and gets it' do
      setup_rig_game(player_cards: [[card('A', 'Clubs')], [card('A', 'Spades')]])
      round_result = game.play_round('A', PLAYER_NAMES[1])
      expect(round_result.go_fish).to be false
      expect(round_result.resulting_cards).to eq [card('A', 'Spades')]
    end

    it 'The player asks for a card, doesn\'t get it, and gets an identical rank from the deck', :focus do
      setup_rig_game(player_cards: [[card('A', 'Clubs')], [card('2', 'Spades')]], deck: [card('A', 'Spades')])
      round_result = game.play_round('A', PLAYER_NAMES[1])
      expect(round_result.go_fish).to be true
      expect(round_result.got_match).to be true
      expect(round_result.resulting_cards).to eq [card('A', 'Spades')]
    end

    it 'The player asks for a card, doesn\'t get it, and doesn\'t get an identical rank from the deck' do
      setup_rig_game(player_cards: [[card('A', 'Clubs')], [card('2', 'Spades')]], deck: [card('3', 'Spades')])
      round_result = game.play_round('A', PLAYER_NAMES[1])
      expect(round_result.go_fish).to be true
      expect(round_result.got_match).to be false
      expect(round_result.resulting_cards).to eq [card('3', 'Spades')]
    end

    it 'The player starts his turn with no cards, and the deck still has cards' do
      setup_rig_game(deck: [card('A', 'Clubs')])
      game.round_precheck
      expect(game.players[0].hand).to eq [card('A', 'Clubs')]
      expect(game.current_player_index).to eq 0
    end

    it 'The player starts his turn with no cards, and the deck is empty' do
      setup_rig_game(player_cards: [[], [card('A', 'Clubs')]])
      game.round_precheck
      expect(game.players[0].hand).to eq []
      expect(game.current_player_index).to eq 1
    end

    it 'The player completes a book while receiving cards' do
      setup_rig_game(player_cards: [[card('A', 'Clubs'), card('A', 'Diamonds'), card('A', 'Hearts'), card('2', 'Clubs')], [card('A', 'Spades')]])
      round_result = game.play_round('A', PLAYER_NAMES[1])
      expect(round_result.new_books).to eq ['A']
      expect(round_result.resulting_cards).to eq [card('A', 'Spades')]
    end
    
    it 'The game finishes after a single round' do
      setup_rig_game(player_cards: [[card('A', 'Clubs'), card('A', 'Diamonds'), card('A', 'Hearts')], [card('A', 'Spades')]], player_books: [%w( 2 3 4 5 6 7 8 9 10 J Q K ), []])
      expect(game.over?).to be false
      round_result = game.play_round('A', PLAYER_NAMES[1])
      expect(round_result.new_books).to eq ['A']
      expect(round_result.resulting_cards).to eq [card('A', 'Spades')]
      expect(game.over?).to be true
    end
    
  end

  def setup_rig_game(player_cards: [[], []], player_books: [[], []], deck: [])
    game.players.each_with_index do |player, i|
      player.hand = player_cards[i]
      player.books = player_books[i]
    end
    game.deck = CardDeck.new(deck: deck)
    game.first_player_index = 0
  end
  
  def card(rank, suit)
    PlayingCard.new(rank, suit)
  end
end