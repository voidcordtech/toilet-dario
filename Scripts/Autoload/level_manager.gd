extends Node

@warning_ignore_start('unused_signal')
signal player_dead
signal player_win(score: int, time, float)
signal player_ready(player_node: Player)
signal score_added(value: int)
signal score_changed(new_score: int)
signal on_restart
@warning_ignore_restore('unused_signal')

var player: Player


var score: int:
	set(value):
		score = value
		score_changed.emit(score)



func _ready() -> void:
	player_ready.connect(on_player_ready)
	


func pause():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume():
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func add_score(value: int):
	score += value
	score_added.emit(value)

func restart():
	get_tree().reload_current_scene()
	resume()
	UiManager.menu_stack.clear()
	score = 0

func on_player_ready(body: Player):
	player = body
