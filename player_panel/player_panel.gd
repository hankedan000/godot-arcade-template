class_name PlayerPanel
extends Panel

@export var empty_fill = Color(0.7,0.7,0.7)
@export var is_player1 = true
@export var p1_fill = Color(0,0,1)
@export var p2_fill = Color(1,0,0)

var player : Player = null

@onready var boostBar := $HBoxContainer/rightHalf/ProgressBar
@onready var _base_indicator := $HBoxContainer/leftHalf/RoundIndicator

func _ready():
	_base_indicator.get_parent().remove_child(_base_indicator)
	setBoostPercent(100.0)
	setNumRounds(3)
	boostBar.value = 0
	if is_player1:
		$HBoxContainer/rightHalf/ProgressBar.setColor(p1_fill)
		$HBoxContainer/rightHalf/icon.modulate = p1_fill
	else:
		$HBoxContainer/rightHalf/ProgressBar.setColor(p2_fill)
		$HBoxContainer/rightHalf/icon.modulate = p2_fill
	
func bindPlayer(new_player: Player) -> void:
	player = new_player

func setNumRounds(numRounds: int) -> void:
	var indicators := $HBoxContainer/leftHalf
	for child in indicators.get_children():
		child.queue_free()
	
	for n in range(numRounds):
		var indicator := _base_indicator.duplicate() as CheckBox
		indicator.disabled = true
		indicator.set_focus_mode(Control.FOCUS_NONE)
		_setModulate(indicator, 0)
		indicators.add_child(indicator)
		
func setWin(roundNum: int, whoWon: int) -> void:
	var checkBox = ($HBoxContainer/leftHalf).get_child(roundNum-1)
	checkBox.button_pressed = true
	_setModulate(checkBox,whoWon)
	
func setBoostPercent(percent: float) -> void:
	if boostBar:
		boostBar.value = percent
		
func setBoostingEnabled(enabled: bool) -> void:
	$HBoxContainer/rightHalf.visible = enabled
		
func _setModulate(checkbox: CheckBox, whoWon: int) -> void:
	match(whoWon):
		0: checkbox.modulate = empty_fill
		1: checkbox.modulate = p1_fill
		2: checkbox.modulate = p2_fill
		
func _process(_delta):
	if player:
		var boostPerc = player.getBoostPercentRemaining()
		$HBoxContainer/rightHalf/ProgressBar.value = boostPerc
