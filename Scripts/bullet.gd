extends Node3D
class_name Bullet

var stats: GunStats
var direction: Vector3

func _ready() -> void:
	hide()
	get_tree().create_timer(0.02).timeout.connect(show)
	get_tree().create_timer(1).timeout.connect(queue_free)

func _physics_process(delta):
	# Move bullet
	global_position += direction * stats.speed * delta 
