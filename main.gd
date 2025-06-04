extends ColorRect

enum GameState {
	eNewGame,
	eWaitForNewGame,
	eRoundBegin,
	eWaitForSpawn,
	eCountDown,
	ePlay,
	eRoundOver,
	eWaitForReplay,
	eGameOver
}

class PlayerInfo:
	var is_ready: bool = false
	var score: int = 0

var gs = GameState.eNewGame
var curr_game_opts: GameOptions = null
var curr_round: int = 1
var p1_info:= PlayerInfo.new()
var p2_info:= PlayerInfo.new()

@onready var player1:= $player
@onready var player2:= $player2
@onready var game_summary1:= $GameSummary
@onready var game_summary2:= $GameSummary2
@onready var p1_how_to:= $p1HowTo
@onready var p2_how_to:= $p2HowTo
@onready var p1_label:= $p1Label
@onready var p2_label:= $p2Label
@onready var p1_menu:= $p1Menu
@onready var p1_panel: PlayerPanel = $p1Panel
@onready var p2_panel: PlayerPanel = $p2Panel
@onready var count_down_timer:= $count_down
@onready var replay_timer:= $replay

func set_labels(text: String) -> void:
	set_label_visible(true)
	p1_label.set_text(text)
	p2_label.set_text(text)
			
func set_label_visible(new_visible: bool) -> void:
	p1_label.visible = new_visible
	p2_label.visible = new_visible
	
func _input(_event) -> void:
	var p1Actions = ["ui_up","ui_down","ui_left","ui_right","ui_accept"]
	var p2Actions = ["p2_up","p2_down","p2_left","p2_right","p2_button"]
	
	# quit the game when escape is pressed
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	for p1Action in p1Actions:
		if Input.is_action_pressed(p1Action):
			p1_info.is_ready = true
			break
			
	for p2Action in p2Actions:
		if Input.is_action_pressed(p2Action):
			p2_info.is_ready = true
			break
	
func _process(_delta) -> void:
	match(gs):
		GameState.eNewGame:
			p1_menu.visible = true
			player1.visible = false
			player2.visible = false
			p1_label.visible = false
			p2_label.visible = false
			game_summary1.visible = false
			game_summary2.visible = false
			curr_round = 1
			p1_panel.set_num_rounds(0)
			p2_panel.set_num_rounds(0)
			p1_panel.set_boosting_enabled(false)
			p2_panel.set_boosting_enabled(false)
			p1_info.is_ready = false
			p2_info.is_ready = false
			p1_info.score = 0
			p2_info.score = 0
			
			gs = GameState.eWaitForNewGame
			
		GameState.eWaitForNewGame:
			p1_info.is_ready = false
			p2_info.is_ready = false
			
		GameState.eWaitForSpawn:
			var is_first_round := curr_round == 1
			# prevent players from changing direction while
			player1.set_disabled_user_input(true)
			player2.set_disabled_user_input(true)
			
			if not curr_game_opts.is_two_player:
				p2_info.is_ready = true
				
			# show how to play graphic
			p1_how_to.visible = is_first_round and TheArcade.is_arcade_mode() and not p1_info.is_ready
			p2_how_to.visible = is_first_round and TheArcade.is_arcade_mode() and not p2_info.is_ready
			
			p1_menu.visible = false
			set_labels("Round %d\nPress button to enter play!" % curr_round)
			p1_label.visible = not p1_info.is_ready
			p2_label.visible = not p2_info.is_ready
			player1.visible = p1_info.is_ready
			player2.visible = p2_info.is_ready
				
			if p1_info.is_ready and p2_info.is_ready:
				gs = GameState.eRoundBegin
			
		GameState.eRoundBegin:
			p1_info.is_ready = false
			p2_info.is_ready = false
			
			if curr_round > curr_game_opts.number_of_rounds:
				gs = GameState.eGameOver
			else:
				gs = GameState.eCountDown
				count_down_timer.start(3)
			
		GameState.eCountDown:
			set_labels(str(int(count_down_timer.time_left) + 1))
			
		GameState.ePlay:
			set_label_visible(false)
			
		GameState.eRoundOver:
			# stop both player from moving
			player1.set_stopped(true)
			player2.set_stopped(true)
			
			# star the timer to begin replay
			$replay_timer.start()
			
			# TODO figure out who won the round
			var whoWon = 1
			p1_panel.set_win(curr_round,whoWon)
			p2_panel.set_win(curr_round,whoWon)
			
			if whoWon == 1:
				p1_info.score += 1
			elif whoWon == 2:
				p2_info.score += 1
			
			gs = GameState.eWaitForReplay
			
		GameState.eWaitForReplay:
			pass
			
		GameState.eGameOver:
			game_summary1.set_scores(p1_info.score,p2_info.score)
			game_summary2.set_scores(p1_info.score,p2_info.score)
			game_summary1.visible = true
			game_summary2.visible = true
			
			if p1_info.is_ready or p2_info.is_ready:
				gs = GameState.eNewGame

func _on_replay_timeout():
	curr_round += 1
	gs = GameState.eRoundBegin

func _on_count_down_timeout():
	player1.set_stopped(false)
	player2.set_stopped(false)
	
	# allow players to control again
	player1.set_disabled_user_input(false)
	player2.set_disabled_user_input(not curr_game_opts.is_two_player)
	
	gs = GameState.ePlay

func _on_p1Menu_game_start(opts: GameOptions) -> void:
	curr_game_opts = opts
	p1_panel.set_num_rounds(curr_game_opts.number_of_rounds)
	p2_panel.set_num_rounds(curr_game_opts.number_of_rounds)
	p1_panel.set_boosting_enabled(true)
	p2_panel.set_boosting_enabled(true)
	p1_panel.set_boost_percent(100.0)
	p2_panel.set_boost_percent(100.0)
	
	# handle 1 vs 2 player mode
	curr_game_opts.is_two_player = opts.is_two_player
		
	gs = GameState.eWaitForSpawn
