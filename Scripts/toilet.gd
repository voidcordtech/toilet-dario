extends StaticBody3D
class_name Toilet

@onready var teleport_position: Marker3D = $TeleportPosition
@onready var cover: MeshInstance3D = $toilet/Cover

@export var interact_box: InteractableBox

const delay_before_win = 3

var level: Level

func _ready() -> void:
	if interact_box.can_interact:
		cover.rotation = Vector3.ZERO
	
	interact_box.interact.connect(on_interact)
	
	

func spin_player(player: Player):
	level = get_tree().current_scene
	
	# Start teleport
	SfxManager.toilet_flush_sfx.play()
	var spin = create_tween()
	player.stop_input()
	set_collision_layer_value(1,0)
	player.global_position = teleport_position.global_position
	spin.tween_property(player.mario, 'rotation:y', player.mario.rotation.y + 6*TAU, 3)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	await spin.finished
	
	# Start Closing cover
	var close_cover = create_tween()
	close_cover.set_trans(Tween.TRANS_CUBIC)
	close_cover.set_ease(Tween.EASE_IN)
	close_cover.tween_property(cover, 'rotation:x', cover.rotation.x + 0.5*PI, 1)
	player.hide()
	
	await close_cover.finished
	SfxManager.toilet_cover_sfx.play()
	await get_tree().create_timer(delay_before_win).timeout
	
	# Done
	LevelManager.player_win.emit(LevelManager.score, level.time)

func on_interact(player: Player):
	spin_player(player)
