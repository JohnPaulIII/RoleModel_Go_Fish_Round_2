require_relative 'broadcaster'
require_relative 'game_manager'
require 'socket'

class FishServer

  attr_accessor :server, :sockets, :player_count_for_game, :manager, :logging

  def initialize(address: 'localhost', port: 3336, logging: true)
    @server = TCPServer.new(address, port)
    @sockets = []
    @player_count_for_game = 0
    @logging = logging
  end

  def puts(text)
    super(text) if logging
  end

  def start
    while true
      accept
      run_game_when_ready
    end
  end

  def accept
    sockets.push(server.accept)
    puts 'New client connection'
    if sockets.count == 1
      sockets[0].puts new_message(:get_new_player_count, "Please enter the number of players you want in the next game:")
      puts @player_count_for_game = sockets[0].gets.to_i 
    end
    @manager = FishGameManager.new(sockets) if ready?
  end

  def run_game_when_ready
    return unless ready?
    puts 'Running game'
    manager.start
    manager.game_loop
    sockets.each { |socket| socket.close }
    @sockets = []
  end

  def ready?
    sockets.count == player_count_for_game
  end

  def close
    server.close
  end

  def new_message(command, message)
    PacketWrapper.new(command: command, message: message).dump
  end

end