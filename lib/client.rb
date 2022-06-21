require_relative 'packet_wrapper'
require_relative 'playing_card'
require_relative 'constants'
include Constants 
require 'socket'
require 'pry'

class FishClient

  attr_accessor :socket, :io_in, :io_out, :cards, :username, :players

  COMMANDS = {
    :general_broadcast => :general_broadcast,
    :get_new_player_count => :get_response,
    :username => :get_response,
    :target_player => :get_target_player,
    :target_rank => :get_target_rank,
    :get_cards => :get_cards,
    :set_players => :set_players,
  }

  EXPANDED_RANKS = {
    'A' => 'Ace',
    'J' => 'Jack',
    'Q' => 'Queen',
    'K' => 'King',
  }

  EXPANDED_SUITS = {
    'C' => 'Clubs',
    'D' => 'Diamonds',
    'H' => 'Hearts',
    'S' => 'Spades',
  }

  def initialize(address: 'localhost', port: Constants::PORT_NUMBER, io_in: STDIN, io_out: STDOUT)
    @socket = TCPSocket.new(address, port)
    @io_in = io_in
    @io_out = io_out
    @cards = []
  end

  def start
    while true
      command_processor(socket.gets.chomp)
    end
  end

  def command_processor(broadcast_string)
    broadcast = Marshal.load(broadcast_string)
    send COMMANDS.fetch(broadcast.command, broadcast.command), broadcast.message
  end

  def general_broadcast(message)
    io_out.puts message
  end

  def get_response(message)
    io_out.puts message
    socket.puts io_in.gets
  end

  def get_username(message)
    io_out.puts message
    @username = io_in.gets
    socket.puts username
  end

  def get_target_player(message)
    io_out.puts message
    result = io_in.gets.chomp
    until players.include?(result)
      io_out.puts 'Invalid target.  Please enter a valid player username'
      result = io_in.gets
    end
    socket.puts result
  end
  
  def get_cards(card_array)
    cards.push(*card_array)
    io_out.puts 'You have:'
    cards.each do |card|
      rank = EXPANDED_RANKS.fetch(card[0..-2],card[0..-2])
      suit = EXPANDED_SUITS[card[-1]]
      io_out.puts "#{rank} of #{suit}"
    end
  end

  def get_target_rank(message)
    io_out.puts message
    result = io_in.gets.chomp
    until PlayingCard::RANKS.include?(result)
      io_out.puts 'Invalid rank.  Please enter a valid rank'
      result = io_in.gets
    end
    socket.puts result
  end

  def set_players(player_array)
    @players = player_array.select { |player| player != username }
  end

end