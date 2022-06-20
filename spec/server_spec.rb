require 'server'
require_relative 'spec_constants'
include Constants
require 'pry'

describe 'FishServer' do
  
  attr_accessor :server

  before(:each) do
    @server = FishServer.new(port: Constants::TEST_PORT_NUMBER, logging: false)
  end

  after(:each) do
    server.close
  end

  it 'opens a server, accepts new players, and asks the first player how many players to allow for the next game' do
    new_client.puts '2'
    expect { server.accept }.to change { server.sockets.count }.from(0).to(1)
    expect(server.player_count_for_game).to eq 2
  end

  it 'creates a GameManager after 2 clients are connected' do
    new_client.puts '2'
    new_client
    server.accept
    expect(server.manager).to be nil
    expect { server.accept }.to change { server.manager }
  end

  def new_client
    TCPSocket.new('localhost', Constants::TEST_PORT_NUMBER)
  end

end
