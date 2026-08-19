extends Control


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	UiManager.menu_stack.clear()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
