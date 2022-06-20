require 'playing_card'

describe 'PlayingCard' do

  it 'can ignore invalid ranks and suits' do
    expect(PlayingCard.new('B', 'Hearts').rank).to eq ''
    expect(PlayingCard.new('K', 'Rubies').suit).to eq ''
  end

  it 'can compare cards by rank' do
    expect(PlayingCard.new('J', 'Diamonds')).to eq PlayingCard.new('J', 'Clubs')
    expect(PlayingCard.new('3', 'Spades')).to_not eq PlayingCard.new('5', 'Spades')
  end

end