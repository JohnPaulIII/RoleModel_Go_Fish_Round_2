require 'card_deck'
require 'playing_card'

describe 'CardDeck' do

  it 'initializes with a full deck' do
    card_total = PlayingCard::RANKS.length * PlayingCard::SUITS.length
    expect(CardDeck.new.card_count).to eq card_total
  end

  it 'deals out a card' do
    deck = CardDeck.new
    card_total = deck.card_count
    deck.deal
    expect(deck.card_count).to eq card_total - 1
  end
  
  it 'knows when it\'s out of cards' do
    deck = CardDeck.new
    card_total = PlayingCard::RANKS.length * PlayingCard::SUITS.length
    expect(!deck.out?)
    card_total.times { deck.deal }
    expect(deck.out?)
  end

end