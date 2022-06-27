require_relative 'card_deck'
require_relative 'playing_card'
require_relative 'player'
require_relative 'broadcaster'

class FishGame

  STARTING_HAND_COUNT = 7

  attr_accessor :players, :deck, :round, :first_player_index, :round_result
  def initialize(player_names: [], deck: CardDeck.new, broadcast: Broadcaster.new)
    @players = player_names.map { |name| FishPlayer.new(name: name)}
    @deck = deck
    @round = 0
    @first_player_index = (0..players.count - 1).to_a.sample
  end

  def start
    deck.shuffle!
    STARTING_HAND_COUNT.times { players.each { |player| player.take_cards(deck.deal)} }
  end

  def current_player_index
    (round + first_player_index) % players.count
  end

  def current_player
    players[current_player_index]
  end

  def round_precheck
    return unless current_player.count_cards == 0
    if deck.out?
      @round += 1
      round_precheck
    else
      current_player.take_cards(deck.deal)
    end
  end

  def play_round(rank, askee)
    @round_result = RoundResult.new(current_player.name, askee, rank)
    transfer_cards(rank, askee)
    @round_result
  end

  def transfer_cards(rank, askee)
    cards = get_player(askee).give_cards(rank)
    if cards.empty?
      @round_result.go_fish = true
      go_fish(rank)
    else
      @round_result.resulting_cards = cards
      round_result.new_books = current_player.take_cards(cards)
    end
  end

  def get_player(name)
    players.find { |player| player.name == name}
  end

  def go_fish(rank)
    @round += 1 if deck.out?
    return if deck.out?
    card = deck.deal
    round_result.resulting_cards = [card]
    round_result.new_books = current_player.take_cards(card)
    round_result.got_match = card.rank == rank
    @round += 1 if card.rank != rank
  end

  def over?
    book_count = 0
    players.each { |player| book_count += player.books.count}
    book_count >= PlayingCard::RANKS.count
  end

  def get_abbreviated_player_cards
    current_player.hand.map { |card| "#{card.rank}#{card.suit[0]}"   }
  end

end

class RoundResult

  attr_accessor :current_player, :target_player, :rank, :go_fish, :got_match, :new_books, :resulting_cards

  def initialize(current_player, target_player, rank)
    @current_player = current_player
    @target_player = target_player
    @rank = rank
    @go_fish = false
    @got_match = false
    @new_books = []
    @resulting_cards = []
  end

end