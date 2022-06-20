require 'game_manager'
require_relative 'spec_constants'
include Constants
require 'socket'
require 'pry'

describe 'FishGameManager' do

  attr_accessor :server, :clients, :sockets, :manager

  before(:each) do
    @server = TCPServer.new('localhost', Constants::TEST_PORT_NUMBER)
    @clients = (0..1).to_a.map { TCPSocket.new('localhost', Constants::TEST_PORT_NUMBER) }
    @sockets = (0..1).to_a.map { server.accept }
    clients.each_with_index { |socket, i| socket.puts Constants::PLAYER_NAMES[i]}
    @manager = FishGameManager.new(sockets)
    manager.start
  end

  after(:each) do
    clients.each { |client| client.close }
    server.close
  end

  it 'takes an array of sockets and creates a game and broadcaster' do
    sockets.each_with_index do |socket, i|
      expect(manager.broadcast.sockets[Constants::PLAYER_NAMES[i]]).to eq socket
      expect(manager.game.players[i].name).to eq Constants::PLAYER_NAMES[i]
    end
  end
  
end