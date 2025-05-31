class_name Player
extends CharacterBody2D

@export var player_fill: Color = Color()
@export var is_player1: bool = false

signal hit(obj: Player, other)
signal boost_changed(boost_remaining_perc: float)

# the max duration a player can boost for a given round
const BOOSTING_DURATION = 3.0
const SPEED_SCALE = 2
# an additional scaling factor ontop of the speed
# when the boost button is pressed
const BOOST_SCALE = 1.8

var boost_dur_left = BOOSTING_DURATION
var spawn_position := Vector2()
var curr_velocity := Vector2()
var stopped = false
var boosting = false
var boosting_enabled = false
# prevents someone from controlling player 2 while AI is playing
var disable_user_input = false
var next_dir: String = "null"
var curr_dir: String = "null"

func _ready():
	$ArcadeInput.is_player1 = is_player1
	spawn_position = global_position
	$fill.color = player_fill
	$GPUParticles2D.process_material.color = player_fill
	# this is a hack to make the particles different between players
	# otherwise, both players ProcessMaterial have the same color
	($GPUParticles2D).process_material = ($GPUParticles2D).process_material.duplicate()
	
	add_to_group("player_body")
	respawn()
	
func set_disabled_user_input(disabled: bool) -> void:
	disable_user_input = disabled
	
func respawn() -> void:
	global_position = spawn_position
	boost_dur_left = BOOSTING_DURATION
	curr_velocity = Vector2()
	next_dir = "u"
	curr_dir = "null"
	rotation = 0 + _get_perspective_rotation()
	$fill.visible = true
	$GPUParticles2D.emitting = false
	stopped = true
	boosting = false
	boost_changed.emit(get_boost_percent_remaining())
	
func get_boost_percent_remaining() -> float:
	var cappedBoostLeft = boost_dur_left
	
	# make sure boost duration fall between 0 and MAX
	cappedBoostLeft = max(0,cappedBoostLeft)
	cappedBoostLeft = min(BOOSTING_DURATION,cappedBoostLeft)
	
	return cappedBoostLeft / BOOSTING_DURATION * 100.0
	
func set_stopped(new_stopped: bool) -> void:
	self.stopped = new_stopped

func explode() -> void:
	($fill).visible = false
	($GPUParticles2D).emitting = true
	stopped = true
	
func give_input(dir: String) -> void:
	if dir == "l" and not (curr_dir in ["l","r"]):
		next_dir = "l"
	elif dir == "r" and not (curr_dir in ["l","r"]):
		next_dir = "r"
	elif dir == "u" and not (curr_dir in ["u","d"]):
		next_dir = "u"
	elif dir == "d" and not (curr_dir in ["u","d"]):
		next_dir = "d"
		
func setboosting_enabled(enabled: bool) -> void:
	boosting_enabled = enabled

func setBoosting(new_boosting: bool) -> void:
	self.boosting = new_boosting

func _input(event) -> void:
	if disable_user_input:
		# don't handle this event
		return
		
	var isPress = event.is_pressed()
	
	if isPress:
		if event.is_action($ArcadeInput.get_player_action("l")):
			give_input("l")
		elif event.is_action($ArcadeInput.get_player_action("r")):
			give_input("r")
		elif event.is_action($ArcadeInput.get_player_action("u")):
			give_input("u")
		elif event.is_action($ArcadeInput.get_player_action("d")):
			give_input("d")
	
	if event.is_action($ArcadeInput.get_player_action("b")):
		setBoosting(isPress)

func _get_perspective_rotation() -> float:
	if is_player1:
		return 0
	return PI

func get_next_velocity() -> Vector2:
	var nextRot = 0
	
	match(next_dir):
		"l":
			nextRot = -PI/2
		"r":
			nextRot = PI/2
		"u":
			nextRot = 0
		"d":
			nextRot = PI
	
	# for perspective rotation
	nextRot += _get_perspective_rotation()
	
	var next_v : Vector2 = curr_velocity
	if curr_dir != next_dir:
		# apply perspective rotation
		rotation = nextRot
		curr_dir = next_dir
		
		next_v = Vector2(0,-1) * SPEED_SCALE
		next_v = next_v.rotated(rotation)
		
	return next_v
	
func _physics_process(delta) -> void:
	if not stopped:
		var boost_factor = 1.0
		if boosting_enabled and boosting and boost_dur_left > 0:
			boost_changed.emit(get_boost_percent_remaining())
			boost_dur_left -= delta
			boost_factor = BOOST_SCALE
		
		curr_velocity = get_next_velocity()
		
		var collision_info := move_and_collide(curr_velocity * boost_factor)
		if collision_info:
			var other := collision_info.get_collider()
			hit.emit(self, other)
