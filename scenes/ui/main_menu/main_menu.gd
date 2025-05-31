class_name MainMenu
extends PanelContainer

signal game_start(opts: GameOptions)

@onready var round_slider:= $VBoxContainer/rounds/HSlider
@onready var cp_1or2_player:= $ControlPanel1or2Player

func _ready():
	var arcade_mode := TheArcade.is_arcade_mode()
	cp_1or2_player.visible = arcade_mode
	$VBoxContainer/p1p2text.visible = arcade_mode
	$VBoxContainer/buttons.visible = not arcade_mode

func _input(event):
	if TheArcade.is_arcade_mode() and visible:
		if event.is_action_released("p1_start"):
			_start_new_game(false)
		elif event.is_action_released("p2_start"):
			_start_new_game(true)

func _on_start1P_pressed():
	if visible:
		_start_new_game(false)

func _on_start2P_pressed():
	if visible:
		_start_new_game(true)
		
func _start_new_game(is_two_player: bool):
	game_start.emit(GameOptions.new(round_slider.value, is_two_player))

func _on_VBoxContainer_visibility_changed():
	if TheArcade.is_arcade_mode():
		# when menu become visible, default to slider focused
		$VBoxContainer/rounds/HSlider.grab_focus()
	else:
		# when menu become visible, default to 1p start focused
		$VBoxContainer/buttons/start1P.grab_focus()
