class_name PlayerPanel
extends Panel

@export var empty_fill = Color(0.7,0.7,0.7)
@export var is_player1 = true
@export var p1_fill = Color(0,0,1)
@export var p2_fill = Color(1,0,0)

var _player : Player = null

@onready var boost_bar := $HBoxContainer/rightHalf/ProgressBar
@onready var _base_indicator := $HBoxContainer/leftHalf/RoundIndicator

func _ready() -> void:
	_base_indicator.get_parent().remove_child(_base_indicator)
	set_boost_percent(100.0)
	set_num_rounds(3)
	boost_bar.value = 0
	if is_player1:
		$HBoxContainer/rightHalf/ProgressBar.setColor(p1_fill)
		$HBoxContainer/rightHalf/icon.modulate = p1_fill
	else:
		$HBoxContainer/rightHalf/ProgressBar.setColor(p2_fill)
		$HBoxContainer/rightHalf/icon.modulate = p2_fill
	
func bind_player(new_player: Player) -> void:
	_player = new_player

func set_num_rounds(numRounds: int) -> void:
	var indicators := $HBoxContainer/leftHalf
	for child in indicators.get_children():
		child.queue_free()
	
	for n in range(numRounds):
		var indicator := _base_indicator.duplicate() as CheckBox
		indicator.disabled = true
		indicator.set_focus_mode(Control.FOCUS_NONE)
		_set_modulate(indicator, 0)
		indicators.add_child(indicator)
		
func set_win(roundNum: int, whoWon: int) -> void:
	var checkBox = ($HBoxContainer/leftHalf).get_child(roundNum-1)
	checkBox.button_pressed = true
	_set_modulate(checkBox,whoWon)
	
func set_boost_percent(percent: float) -> void:
	if boost_bar:
		boost_bar.value = percent
		
func set_boosting_enabled(enabled: bool) -> void:
	$HBoxContainer/rightHalf.visible = enabled
		
func _set_modulate(checkbox: CheckBox, whoWon: int) -> void:
	match(whoWon):
		0: checkbox.modulate = empty_fill
		1: checkbox.modulate = p1_fill
		2: checkbox.modulate = p2_fill
		
func _process(_delta) -> void:
	if _player:
		var boostPerc = _player.get_boost_percent_remaining()
		$HBoxContainer/rightHalf/ProgressBar.value = boostPerc
