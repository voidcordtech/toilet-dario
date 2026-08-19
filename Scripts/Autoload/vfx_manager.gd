extends Node

@export_group('Particle')
@export var blood_vfx: PackedScene
@export var small_explosion_vfx: PackedScene
@export var break_bricks_vfx: PackedScene
@export var enemy_hurt_vfx: PackedScene

@export_group('Score')
@export var pop_score_vfx: PackedScene

# Splittable
@export_group('Splittable')
@export var mushroom_splittable: PackedScene

func add_vfx(vfx_name: PackedScene, spawn_position: Vector3, direction := Vector3.ZERO):
	var vfx = vfx_name.instantiate()
	if vfx is Node3D:
		get_tree().current_scene.add_child(vfx)
		vfx.global_position = spawn_position
		vfx.look_at(direction)
		if vfx is GPUParticles3D:
			vfx.finished.connect(vfx.queue_free)
			vfx.restart()

func add_splittable(scene_path: PackedScene, spawn_position: Vector3, spawn_amount: int = 1):
	for i in spawn_amount:
		var splittable = scene_path.instantiate()
		if splittable is Splittable:
			get_tree().current_scene.add_child(splittable)
			get_tree().create_timer(splittable.spawn_duration).timeout.connect(splittable.queue_free)
			splittable.global_position = spawn_position

func pop_score(vfx_name: PackedScene, spawn_position: Vector3, value: int):
	var vfx = vfx_name.instantiate()
	var text_prefix: String
	if vfx is Label3D:
		get_tree().current_scene.add_child(vfx)
		vfx.global_position = spawn_position
		
		if value > 0:
			vfx.modulate = Color.GREEN
			text_prefix = '+ '
		
		vfx.text = text_prefix + str(value)
