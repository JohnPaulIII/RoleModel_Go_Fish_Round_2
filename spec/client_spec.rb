require 'client'
require_relative 'spec_constants'
include Constants
require 'pry'

class MockOutput

  attr_accessor :messages

  def initialize
    @messages = []
  end

  def puts(text)
    messages.push(text)
  end

  def posts
    messages
  end

end

class MockInput

  attr_accessor :inputs

  def initialize
    @inputs = []
  end

  def set_input(text)
    @inputs.push(*text)
  end

  def gets
    @inputs.shift
  end

end

describe 'FishClient' do

  attr_accessor :server, :mock_input, :mock_output, :client, :socket

  before(:each) do
    @server = TCPServer.new('localhost', Constants::TEST_PORT_NUMBER)
    @mock_input = MockInput.new
    @mock_output = MockOutput.new
    @client = FishClient.new(port: Constants::TEST_PORT_NUMBER, io_in: @mock_input, io_out: @mock_output)
    @socket = @server.accept
  end

  after(:each) do
    server.close
  end

  describe '#command_processor' do

    it 'can receive a general broadcast and show it on terminal' do
      client.command_processor(new_message(:general_broadcast, 'Welcome to Go Fish!'))
      expect(mock_output.posts).to eq ['Welcome to Go Fish!']
    end
    
    it 'can query for the number of players for the next game' do
      mock_input.set_input('2')
      client.command_processor(new_message(:get_new_player_count, 'Please enter the number of players you want in the next game:'))
      expect(mock_output.posts).to eq ['Please enter the number of players you want in the next game:']
      expect(socket.gets.chomp).to eq '2'
    end

    it 'can query the player for a username' do
      mock_input.set_input('Josh')
      client.command_processor(new_message(:username, 'Please provide a username:'))
      expect(mock_output.posts).to eq ['Please provide a username:']
      expect(socket.gets.chomp).to eq 'Josh'
    end

    it 'can store the opponents received from the server' do
      client.username = 'Josh'
      client.command_processor(new_message(:set_players, Constants::PLAYER_NAMES))
      expect(client.players).to eq Constants::PLAYER_NAMES[1,2]
    end

    it 'can query the player for a target player' do
      client.players = Constants::PLAYER_NAMES[1,2]
      mock_input.set_input('Braden')
      client.command_processor(new_message(:target_player, 'Please pick an opponent to ask for cards:'))
      expect(mock_output.posts).to eq ['Please pick an opponent to ask for cards:']
      expect(socket.gets.chomp).to eq 'Braden'
    end

    it 'checks for a valid target player' do
      client.players = Constants::PLAYER_NAMES[1,2]
      mock_input.set_input(['Caleb', 'Braden'])
      client.command_processor(new_message(:target_player, 'Please pick an opponent to ask for cards:'))
      expect(mock_output.posts).to eq ['Please pick an opponent to ask for cards:', "Invalid target.  Please enter a valid player username"]
      expect(socket.gets.chomp).to eq 'Braden'
    end

    it 'can query the player for a target rank' do
      mock_input.set_input('A')
      client.command_processor(new_message(:target_rank, 'Please pick a rank to ask for:'))
      expect(mock_output.posts).to eq ['Please pick a rank to ask for:']
      expect(socket.gets.chomp).to eq 'A'
    end
    
    it 'checks for a valid target rank' do
      mock_input.set_input(['Ace', 'A'])
      client.command_processor(new_message(:target_rank, 'Please pick a rank to ask for:'))
      expect(mock_output.posts).to eq ['Please pick a rank to ask for:', "Invalid rank.  Please enter a valid rank"]
      expect(socket.gets.chomp).to eq 'A'
    end
    
    it 'can receive cards from the server' do
      client.command_processor(new_message(:get_cards, %w( AH 2S 10C KD )))
      expect(client.cards).to eq %w( AH 2S 10C KD )
      expect(mock_output.posts).to eq ['You have:', 'Ace of Hearts', '2 of Spades', '10 of Clubs', 'King of Diamonds']
    end

  end

  def new_message(command, message)
    PacketWrapper.new(command: command, message: message).dump
  end

end