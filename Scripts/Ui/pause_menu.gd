extends Control

@export var menu_manager: MenuManager

func _ready() -> void:
	hide()

func _on_resume_button_pressed() -> void:
	UiManager.pop_menu()
	LevelManager.resume()

func _on_settings_button_pressed() -> void:
	UiManager.push_menu(menu_manager.settings_menu)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
