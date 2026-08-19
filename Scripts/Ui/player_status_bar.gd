extends Control

@onready var progress_bar: ProgressBar = $BottomBar/MarginContainer/ProgressBar
@onready var ammo_row: HBoxContainer = %AmmoRow
@onready var cross_hair: TextureRect = %CrossHair
@onready var skip_button: Button = %SkipButton
@onready var time: Label = %Time

@export var score: Label 
@export var increment_speed: int = 5
@export var ammo_label: Label
@export var reload_progress: TextureProgressBar

var player: Player
var op: CutScene
var level: Level

var current_score: int = 0
var real_score: int
var current_time: float




func _ready() -> void:
	op = get_tree().get_first_node_in_group('cut_scene')
	player = get_tree().get_first_node_in_group('player')
	level = get_tree().current_scene
	
	skip_button.pressed.connect(skip_opening)
	op.level_started.connect(skip_button.hide)
	
	
	progress_bar.max_value = player.health_component.max_health
	reload_progress.hide()
	ammo_row.hide()
	

func _process(delta: float) -> void:
	if player:
		progress_bar.value = player.health_component.health
		
		if player.current_gun:
		# Ammo
			cross_hair.show()
			ammo_row.show()
			ammo_label.text = str(player.current_gun.current_ammo) + '/∞'
			
			if player.is_reloading:
				reload_progress.show()
				cross_hair.hide()
				reload_progress.max_value = player.gun_reload_cd.wait_time
				reload_progress.value = player.gun_reload_cd.time_left
			else:
				reload_progress.hide()
				cross_hair.show()
		else:
			cross_hair.hide()
	
	# Score
	real_score = LevelManager.score
	slowly_increment_score(delta)
	score.text = str(current_score)
	
	# Time
	current_time = level.time
	time.text = str(int(current_time)) + ' s'
	


func slowly_increment_score(_delta: float):
	if current_score < real_score:
		current_score += increment_speed
	elif current_score > real_score:
		current_score -= increment_speed

func on_player_ready(body: Player):
	player = body

func skip_opening():
	if op is CutScene:
		op.skip()

func hide_skip_button():
	skip_button.hide()
