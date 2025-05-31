class_name Player
extends CharacterBody2D

@export var player_fill : Color = Color()
@export var isPlayer1 : bool = false

signal hit(obj: Player, other)
signal boost_changed(boost_remaining_perc: float)

# the max duration a player can boost for a given round
const BOOSTING_DURATION = 3.0
const SPEED_SCALE = 2
# an additional scaling factor ontop of the speed
# when the boost button is pressed
const BOOST_SCALE = 1.8

var boostDurLeft = BOOSTING_DURATION
var spawnPosition = Vector2()
var v = Vector2()
var stopped = false
var boosting = false
var boostingEnabled = false
# prevents someone from controlling player 2 while AI is playing
var disableUserInput = false
var nextDir = "null"
var currDir = "null"

func _ready():
	$ArcadeInput.is_player1 = isPlayer1
	spawnPosition = global_position
	$fill.color = player_fill
	$GPUParticles2D.process_material.color = player_fill
	# this is a hack to make the particles different between players
	# otherwise, both players ProcessMaterial have the same color
	($GPUParticles2D).process_material = ($GPUParticles2D).process_material.duplicate()
	
	add_to_group("player_body")
	respawn()
	
func setDisableUserInput(disabled):
	disableUserInput = disabled
	
func respawn():
	global_position = spawnPosition
	boostDurLeft = BOOSTING_DURATION
	v = Vector2()
	nextDir = "u"
	currDir = "null"
	rotation = 0 + _getPerspectiveRotation()
	$fill.visible = true
	$GPUParticles2D.emitting = false
	stopped = true
	boosting = false
	boost_changed.emit(getBoostPercentRemaining())
	
func getBoostPercentRemaining():
	var cappedBoostLeft = boostDurLeft
	
	# make sure boost duration fall between 0 and MAX
	cappedBoostLeft = max(0,cappedBoostLeft)
	cappedBoostLeft = min(BOOSTING_DURATION,cappedBoostLeft)
	
	return cappedBoostLeft / BOOSTING_DURATION * 100.0
	
func setStopped(new_stopped: bool) -> void:
	self.stopped = new_stopped

func explode() -> void:
	($fill).visible = false
	($GPUParticles2D).emitting = true
	stopped = true
	
func turnLeft():
	# map used to convert absolute dir needed to turn left
	var DIR_MAP = {
		"u":"l",
		"l":"d",
		"d":"r",
		"r":"u"}
		
	giveInput(DIR_MAP[currDir])

func turnRight():
	# map used to convert absolute dir needed to turn right
	var DIR_MAP = {
		"u":"r",
		"l":"u",
		"d":"l",
		"r":"d"}
		
	giveInput(DIR_MAP[currDir])

func giveInput(dir):
	if dir == "l" and not (currDir in ["l","r"]):
		nextDir = "l"
	elif dir == "r" and not (currDir in ["l","r"]):
		nextDir = "r"
	elif dir == "u" and not (currDir in ["u","d"]):
		nextDir = "u"
	elif dir == "d" and not (currDir in ["u","d"]):
		nextDir = "d"
		
func setBoostingEnabled(enabled: bool) -> void:
	boostingEnabled = enabled

func setBoosting(new_boosting: bool) -> void:
	self.boosting = new_boosting

func _input(event):
	if disableUserInput:
		# don't handle this event
		return
		
	var isPress = event.is_pressed()
	
	if isPress:
		if event.is_action($ArcadeInput.get_player_action("l")):
			giveInput("l")
		elif event.is_action($ArcadeInput.get_player_action("r")):
			giveInput("r")
		elif event.is_action($ArcadeInput.get_player_action("u")):
			giveInput("u")
		elif event.is_action($ArcadeInput.get_player_action("d")):
			giveInput("d")
	
	if event.is_action($ArcadeInput.get_player_action("b")):
		setBoosting(isPress)

func _getPerspectiveRotation():
	if isPlayer1:
		return 0
	return PI

func getDir():
	return currDir

func getVelocity():
	var nextRot = 0
	
	match(nextDir):
		"l":
			nextRot = -PI/2
		"r":
			nextRot = PI/2
		"u":
			nextRot = 0
		"d":
			nextRot = PI
	
	# for perspective rotation
	nextRot += _getPerspectiveRotation()
	
	var next_v = v
	if currDir != nextDir:
		# apply perspective rotation
		rotation = nextRot
		currDir = nextDir
		
		next_v = Vector2(0,-1) * SPEED_SCALE
		next_v = next_v.rotated(rotation)
		
	return next_v
	
func _physics_process(delta):
	if not stopped:
		var boost_factor = 1.0
		if boostingEnabled and boosting and boostDurLeft > 0:
			boost_changed.emit(getBoostPercentRemaining())
			boostDurLeft -= delta
			boost_factor = BOOST_SCALE
		
		v = getVelocity()
		
		var collision_info := move_and_collide(v * boost_factor)
		if collision_info:
			var other := collision_info.get_collider()
			hit.emit(self, other)
