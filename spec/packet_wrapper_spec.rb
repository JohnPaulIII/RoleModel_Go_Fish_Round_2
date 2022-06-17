require_relative '../lib/packet_wrapper'
require_relative 'spec_constants'
include Constants  

describe 'PacketWrapper' do

  it 'marshals and unmarshals correctly' do
    packet = PacketWrapper.new(command: :command, message: 'This is "not" a test')
    packet_string = packet.dump
    reloaded_packet = Marshal.load(packet_string)
    expect(reloaded_packet).to eq packet
  end

end