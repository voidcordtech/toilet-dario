extends Area3D


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		SfxManager.water_sfx.play()
		body.camera_pivot.reparent(get_tree().current_scene)
		body.stop_input()
		
		await get_tree().create_timer(2).timeout
		body.health_component.dead.emit()
