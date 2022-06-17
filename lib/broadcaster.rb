require_relative 'packet_wrapper'

class Broadcaster

  attr_accessor :sockets

  def initialize(names, sockets)
    @sockets = {}
    names.each_index { |i| @sockets[names[i]] = sockets[i] }
  end

  def send_regular_message(recipient, message, invert: false)
    if recipient == :all
      sockets.each_value { |socket| socket.puts new_message(:general, message)}
    elsif invert
      sockets.select {|name, _| name != recipient }.each_value { |socket| socket.puts new_message(:general, message)}
    else
      sockets[recipient].puts new_message(:general, message)
    end
  end

  def new_message(command, message)
    PacketWrapper.new(command: command, message: message).dump
  end
  
end