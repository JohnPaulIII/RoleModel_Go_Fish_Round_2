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
    broadcast.set_players
    @game = FishGame.new(player_names: broadcast.sockets.keys, broadcast: broadcast)
  end

  def game_loop
    game.start
    while !game.over?
      broadcast.send_cards(game.current_player.name, game.get_abbreviated_player_cards)
      puts target_player = broadcast.get_target_player(game.current_player.name)
      puts target_rank = broadcast.get_target_rank(game.current_player.name)
      broadcast.send_round_results(game.play_round(target_rank, target_player))
    end
  end

end