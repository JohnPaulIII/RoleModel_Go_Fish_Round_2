require_relative 'packet_wrapper'
require_relative 'constants'
include Constants 
require 'socket'

class FishClient

  attr_accessor :socket, :io_in, :io_out, :cards

  COMMANDS = {
    :general_broadcast => :general_broadcast,
    :get_new_player_count => :get_response,
    :username => :get_response,
    :target_player => :get_response,
    :target_rank => :get_response,
    :get_cards => :get_cards,
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
    send COMMANDS[broadcast.command], broadcast.message
  end

  def general_broadcast(message)
    io_out.puts message
  end

  def get_response(message)
    io_out.puts message
    @socket.puts io_in.gets
  end
  
  def get_cards(card_array)
    cards.push(*card_array)
  end

end