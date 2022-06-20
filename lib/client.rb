require_relative 'packet_wrapper'
require_relative 'constants'
include Constants 
require 'socket'

class FishClient

  attr_accessor :socket, :io_in, :io_out

  COMMANDS = {
    :general_broadcast => :general_broadcast,
    :get_new_player_count => :get_new_player_count,
    :username => :get_username,
    :target_player => :get_target_player,
    :target_rank => :get_target_rank,
  }

  def initialize(address: 'localhost', port: Constants::PORT_NUMBER, io_in: STDIN, io_out: STDOUT)
    @socket = TCPSocket.new(address, port)
    @io_in = io_in
    @io_out = io_out
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

  def get_new_player_count(message)
    io_out.puts message
    @socket.puts io_in.gets
  end

  def get_username(message)
    io_out.puts message
    @socket.puts io_in.gets
  end

  def get_target_player(message)
    io_out.puts message
    @socket.puts io_in.gets
  end

  def get_target_rank(message)
    io_out.puts message
    @socket.puts io_in.gets
  end
  
end