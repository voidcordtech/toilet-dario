extends Button

@export var main_menu: PackedScene

func _on_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu)
	LevelManager.restart()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
