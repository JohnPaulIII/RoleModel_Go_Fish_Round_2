require_relative '../lib/player'

describe 'GoFishPlayer' do 
  it 'initalizes with no arguments' do 
    player = FishPlayer.new
    expect(player.name).to eq ''
    expect(player.hand).to eq []
    expect(player.books).to eq []
  end
  it 'initializes with arguments' do 
    player = FishPlayer.new(name: 'Josh', hand: [card('A', 'Spades')], books: ['A'])
    expect(player.name).to eq 'Josh'
    expect(player.hand).to eq [card('A', 'Spades')]
    expect(player.books).to eq ['A']
  end

  it 'takes cards' do 
    player = FishPlayer.new(name: 'Josh', hand: [card('A', 'Spades')])
    player.take_cards(card('A', 'Hearts'))
    expect(player.hand).to eq [card('A', 'Spades'), card('A', 'Hearts')]
  end

  it 'gives cards' do 
    player = FishPlayer.new(name: 'Josh', hand: [card('A', 'Spades'), card('A', 'Hearts')])
    cards = player.give_cards('A')
    expect(cards).to eq [card('A', 'Spades'), card('A', 'Hearts')]
    expect(player.hand).to eq []
  end

  it 'creates_books' do 
    player = FishPlayer.new(name: 'Josh', hand: [card('A', 'Spades'), card('A', 'Hearts'), card('A', 'Clubs')])
    player.take_cards([card('A', 'Diamonds'), card('2', 'Spades')])
    expect(player.hand).to eq [card('2', 'Spades')]
    expect(player.books.count).to eq 1
  end
   
  it 'counts the cards in hand' do
    player = FishPlayer.new(name: 'Josh', hand: [card('A', 'Spades'), card('A', 'Hearts'), card('A', 'Clubs')])
    expect(player.count_cards).to eq 3
  end

  def card(rank, suit)
    PlayingCard.new(rank, suit)
  end
end