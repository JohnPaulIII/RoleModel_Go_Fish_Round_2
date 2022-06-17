require_relative '../lib/broadcaster'
require_relative 'spec_constants'
require 'socket'
include Constants  

describe 'Broadcaster' do
  

  before(:each) do
    @server = TCPServer.new('localhost', Constants::TEST_PORT_NUMBER)
    @clients = (0..1).map { TCPSocket.new('localhost', Constants::TEST_PORT_NUMBER) }
    @sockets = (0..1).map { @server.accept }
    @broadcast = Broadcaster.new(Constants::PLAYER_NAMES[0, 2], @sockets)
  end

  after(:each) do
    @server.close
    @clients.each { |client| client.close}
  end

  it 'initializes correctly with the supplied values' do
    expect(@broadcast.sockets.keys).to eq Constants::PLAYER_NAMES[0, 2]
    expect(@broadcast.sockets.values).to eq @sockets
  end

  it 'sends regular broadcasts to clients' do
    @broadcast.send_regular_message(:all, 'Welcome to Go Fish!')
    @clients.each { |client| expect(get_message(client)).to eq [:general, 'Welcome to Go Fish!'] }
    @broadcast.send_regular_message(Constants::PLAYER_NAMES[0], 'You go first')
    expect(get_message(@clients[0])).to eq [:general, 'You go first']
    @broadcast.send_regular_message(Constants::PLAYER_NAMES[0], 'Josh goes first', invert: true)
    expect(get_message(@clients[1])).to eq [:general, 'Josh goes first']
  end


  def get_message(client)
    broadcast = Marshal.load(client.gets)
    [broadcast.command, broadcast.message]
  end

end