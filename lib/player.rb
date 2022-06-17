require 'pry'

class FishPlayer

  attr_accessor :name, :hand, :books
  def initialize(name: '', hand: [], books: [])
    @name = name
    @hand = hand
    @books = books
  end

  def take_cards(cards)
    hand.push(*cards).compact
    check_for_books
  end

  def give_cards(rank)
    cards = hand.select{ |card| card.rank == rank}
    hand.reject! {|card| card.rank == rank}
    cards
  end

  def count_cards
    hand.count
  end

  def check_for_books 
    ranks = []
    hand.map { |card| card.rank }.uniq.each do |card_rank|
      if hand.count { |card| card.rank == card_rank } > 3
        books.push(card_rank)
        hand.reject! { |card| card.rank == card_rank }
      end
    end
    ranks
  end

end