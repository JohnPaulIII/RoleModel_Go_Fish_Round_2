class PlayingCard

  RANKS = %w( 2 3 4 5 6 7 8 9 10 J Q K A )
  SUITS = %w( Clubs Diamonds Hearts Spades )

  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = RANKS.any?(rank) ? rank : ''
    @suit = SUITS.any?(suit) ? suit : ''
  end

  def ==(other)
    RANKS.index(rank) == RANKS.index(other.rank)
  end

  def <=>(other)
    RANKS.index(rank) <=> RANKS.index(other.rank)
  end

  def card_to_string
    rank[-1] + suit[0]
  end

end