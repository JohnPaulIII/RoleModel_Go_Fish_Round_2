require_relative 'card_deck'
require_relative 'playing_card'
require_relative 'player'
require_relative 'broadcaster'

class FishGame

  STARTING_HAND_COUNT = 7

  attr_accessor :players, :deck, :round, :first_player_index, :broadcast
  def initialize(player_names: [], deck: CardDeck.new, broadcast: Broadcaster.new)
    @players = player_names.map { |name| FishPlayer.new(name: name)}
    @deck = deck
    @round = 0
    @first_player_index = (0..players.count - 1).to_a.sample
    @broadcast = broadcast
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
    transfer_cards(rank, askee)
  end

  def transfer_cards(rank, askee)
    cards = get_player(askee).give_cards(rank)
    if cards.empty?
      go_fish(rank)
    else
      current_player.take_cards(cards)
    end
  end

  def get_player(name)
    players.select { |player| player.name == name}[0]
  end

  def go_fish(rank)
    @round += 1 if deck.out?
    return if deck.out?
    card = deck.deal
    current_player.take_cards(card)
    @round += 1 if card.rank != rank
  end

  def over?
    book_count = 0
    players.each { |player| book_count += player.books.count}
    book_count >= PlayingCard::RANKS.count
  end

end