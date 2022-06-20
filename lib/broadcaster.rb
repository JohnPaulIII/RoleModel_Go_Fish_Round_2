require_relative 'packet_wrapper'
require 'pry'

class Broadcaster

  attr_accessor :sockets

  def initialize(names: [], sockets: [])
    @sockets = {}
    names.each_index { |i| @sockets[names[i]] = sockets[i] }
  end

  def send_general_message(recipient, message, invert: false)
    if recipient == :all
      sockets.each_value { |socket| socket.puts new_message(:general_broadcast, message)}
    elsif invert
      sockets.select {|name, _| name != recipient }.each_value { |socket| socket.puts new_message(:general_broadcast, message)}
    else
      sockets.select {|name, _| name == recipient }.each_value { |socket| socket.puts new_message(:general_broadcast, message)}
    end
  end

  def send_cards(player_name, abbreviated_card_array)
    sockets[player_name].puts new_message(:get_cards, abbreviated_card_array)
  end

  def get_target_player(player_name)
    sockets[player_name].puts new_message(:target_player, 'Please pick an opponent to ask for cards:')
    sockets[player_name].gets.chomp
  end

  def get_target_rank(player_name)
    sockets[player_name].puts new_message(:target_rank, 'Please pick a rank to ask for:')
    sockets[player_name].gets.chomp
  end

  def add_user(socket)
    socket.puts new_message(:username, 'Please provide a username:')
    name = socket.gets.chomp
    add_socket(name, socket)
  end

  def add_socket(name, socket)
    sockets[name] = socket
  end

  def new_message(command, message)
    PacketWrapper.new(command: command, message: message).dump
  end
  
end