extends Control

@onready var score_label: Label = %ScoreLabel
@onready var time_label: Label = %TimeLabel

func _ready() -> void:
	LevelManager.player_win.connect(on_win)



func on_win(score: int, time: float):
	score_label.text = 'Score: ' + str(score)
	time_label.text = 'Time: ' + str(snapped(time, 0.01)) + ' s'
