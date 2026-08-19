extends Node
class_name FloatingComponent

@export var target_mesh: Node3D
@export var distance: float = 0.3
@export var duration: float = 1.0 

func _ready() -> void:
	floating()

func floating():
	var start_y = target_mesh.position.y
	var target_y = start_y + distance

	var tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Go up
	tween.tween_property(target_mesh, "position:y", start_y, duration)
	# Go down
	tween.tween_property(target_mesh, "position:y", target_y, duration)

func reset_position():
	target_mesh.position = Vector3.ZERO
