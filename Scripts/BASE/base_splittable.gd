extends Node3D
class_name Splittable

const MAX_FORCE: float = 10.0
@export var spawn_duration := 5

func _ready() -> void:
	split()

func split():
	var children = get_children()
	for child in children:
		if child is RigidBody3D:
			# Set collision mask layer
			child.set_collision_layer_value(1, 0)
			child.set_collision_layer_value(6, 1)
			
			# Random direction
			var x: float = randf_range(-1, 1)
			var y: float = randf_range(0, 1)
			var z: float = randf_range(-1, 1)
			var direction: Vector3 = Vector3(x,y,z).normalized()
			
			# Random force
			var force = randf_range(3.0, MAX_FORCE)
			
			child.apply_central_impulse(direction * force)
			child.apply_torque_impulse(direction * force)
