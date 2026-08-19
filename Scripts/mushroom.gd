extends RigidBody3D
class_name Collectible

@export var speed :float = 6.0
@export var speed_variation :float = 3
@export var score: int = 100
var target: Player = null
var is_collecting := false

func _process(delta: float) -> void:
	if is_collecting:
		
		var direction = (target.body_marker.global_position - global_position).normalized()
		global_position += direction * delta * speed
		if global_position.distance_to(target.body_marker.global_position) < 0.2:
			collected()


func start_collect(body: Player):
	target = body
	is_collecting = true
	add_speed_variation()

func collected():
	VfxManager.pop_score(VfxManager.pop_score_vfx, target.score_marker.global_position, score)
	SfxManager.mushroom_sfx.play()
	LevelManager.add_score(score)
	queue_free()

func add_speed_variation():
	speed += randf_range(-speed_variation, speed_variation)
