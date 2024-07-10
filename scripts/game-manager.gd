extends Node

@onready var score_display = $ScoreDisplay

var score = 0

func add_points(amount):
	score += amount
	score_display.text = "You collected " + str(score) + " coins."
