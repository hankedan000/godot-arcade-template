class_name GameSummary
extends PanelContainer

@export var p1_fill = Color()
@export var p2_fill = Color()

@onready var p1ScoreText = $GridContainer/HBoxContainer/p1Score
@onready var p2ScoreText = $GridContainer/HBoxContainer/p2Score
@onready var summaryText = $GridContainer/summary

# Called when the node enters the scene tree for the first time.
func _ready():
	p1ScoreText.set("theme_override_colors/font_color",p1_fill)
	p2ScoreText.set("theme_override_colors/font_color",p2_fill)
	
func set_scores(p1Score: int, p2Score: int):
	p1ScoreText.text = str(p1Score)
	p2ScoreText.text = str(p2Score)
	
	var summary = "It's a tie!"
	if p1Score > p2Score:
		summary = "Player 1 wins!"
	elif p2Score > p1Score:
		summary = "Player 2 wins!"
	
	summaryText.text = summary
