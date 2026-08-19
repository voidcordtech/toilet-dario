extends Node3D

@onready var settings_menu: Control = %SettingsMenu
@onready var about_menu: Control = %AboutMenu

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file('res://Scenes/level_1.tscn')


func _on_setting_pressed() -> void:
	UiManager.push_menu(settings_menu)


func _on_about_pressed() -> void:
	UiManager.push_menu(about_menu)
