extends Label3D

@export var duration: float = 1
@export var target_height: float = 1.5  



func _ready() -> void:
	modulate = Color.RED # Default
	
	var pop := create_tween()
	var target_position = global_position.y + target_height
	
	pop.set_ease(Tween.EASE_IN_OUT)
	pop.set_trans(Tween.TRANS_SINE)
	
	pop.tween_property(self, "global_position:y", target_position, duration)
	pop.parallel().tween_property(self, "modulate:a", 0.0, duration + 1)
	pop.parallel().tween_property(self, "outline_modulate:a", 0.0, duration +1)
	
	# Delete when finished
	await pop.finished
	queue_free()
