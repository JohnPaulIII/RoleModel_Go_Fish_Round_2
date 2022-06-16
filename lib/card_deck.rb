require_relative 'playing_card'

class CardDeck

  attr_accessor :deck

  def initialize(card_type: PlayingCard)
    @deck = []
    card_type::RANKS.each do |rank|
      card_type::SUITS.each do |suit|
        @deck.push(card_type.new(rank, suit))
      end
    end
  end

  def card_count
    deck.length
  end

  def out?
    deck.empty?
  end

  def deal
    deck.shift
  end

  def shuffle!
    deck.shuffle!
  end

end