require_relative 'broadcaster'
require_relative 'game'

class FishGameManager
  
  attr_accessor :sockets, :broadcast, :game

  def initialize(sockets)
    @sockets = sockets
  end

  def start
    @broadcast = Broadcaster.new
    @sockets.each { |socket| broadcast.add_user(socket) }
    @game = FishGame.new(player_names: @broadcast.sockets.keys, broadcast: broadcast)
  end

  def game_loop
    while !game.over?
      puts 'getting player'
      puts target_player = broadcast.get_target_player(game.current_player.name)
      puts 'getting rank'
      puts target_rank = broadcast.get_target_rank(game.current_player.name)
      puts game.play_round(target_rank, target_player)
    end
  end

end