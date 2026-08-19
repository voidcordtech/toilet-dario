extends AnimationPlayer
class_name CutScene

signal level_started

@export var op_toilet: Toilet
@export var player: Player



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func skip():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	op_toilet.process_mode = Node.PROCESS_MODE_INHERIT
	
	player.show()
	player.camera_3d.make_current()
	player.restore_input()
	
	level_started.emit()
	queue_free()
