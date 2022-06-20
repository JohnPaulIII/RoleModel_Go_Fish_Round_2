require 'broadcaster'
require_relative 'spec_constants'
include Constants  
require 'socket'

describe 'Broadcaster' do
  
  attr_accessor :server, :clients, :sockets, :broadcast

  before(:each) do
    @server = TCPServer.new('localhost', Constants::TEST_PORT_NUMBER)
    @clients = (0..1).map { TCPSocket.new('localhost', Constants::TEST_PORT_NUMBER) }
    @sockets = (0..1).map { server.accept }
    @broadcast = Broadcaster.new(names: Constants::PLAYER_NAMES[0, 2], sockets: sockets)
  end

  after(:each) do
    server.close
    clients.each { |client| client.close}
  end

  it 'initializes correctly with the supplied values' do
    expect(broadcast.sockets.keys).to eq Constants::PLAYER_NAMES[0, 2]
    expect(broadcast.sockets.values).to eq sockets
  end

  it 'can add additional sockets to the hash' do
    TCPSocket.new('localhost', Constants::TEST_PORT_NUMBER)
    sockets.push(server.accept)
    broadcast.add_socket(Constants::PLAYER_NAMES[2], sockets[2])
  end

  it 'sends regular broadcasts to clients' do
    broadcast.send_general_message(:all, 'Welcome to Go Fish!')
    clients.each { |client| expect(get_message(client)).to eq [:general_broadcast, 'Welcome to Go Fish!'] }
    broadcast.send_general_message(Constants::PLAYER_NAMES[0], 'You go first')
    expect(get_message(clients[0])).to eq [:general_broadcast, 'You go first']
    broadcast.send_general_message(Constants::PLAYER_NAMES[0], 'Josh goes first', invert: true)
    expect(get_message(clients[1])).to eq [:general_broadcast, 'Josh goes first']
  end

  it 'can query a client for a username and add the socket and username to the sockets hash' do
    clients.push(TCPSocket.new('localhost', Constants::TEST_PORT_NUMBER))
    sockets.push(server.accept)
    clients[2].puts Constants::PLAYER_NAMES[2]
    broadcast.add_user(sockets[2])
    expect(broadcast.sockets.keys).to eq Constants::PLAYER_NAMES
    expect(broadcast.sockets.values).to eq sockets
  end

  it 'can send cards to the client' do
    broadcast.send_cards(Constants::PLAYER_NAMES[0], %w( AH 2S 10C KD ))
    expect(get_message(clients[0])).to eq [:get_cards, %w( AH 2S 10C KD )]
  end

  it 'can query a client for a target player and return the resulting name' do
    clients[0].puts Constants::PLAYER_NAMES[1]
    result = broadcast.get_target_player(Constants::PLAYER_NAMES[0])
    expect(result).to eq Constants::PLAYER_NAMES[1]
  end

  it 'can query a client for a target rank and return the resulting name' do
    clients[0].puts 'A'
    result = broadcast.get_target_rank(Constants::PLAYER_NAMES[0])
    expect(result).to eq 'A'
  end


  def get_message(client)
    broadcast = Marshal.load(client.gets)
    [broadcast.command, broadcast.message]
  end

end