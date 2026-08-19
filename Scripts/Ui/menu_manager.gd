extends CanvasLayer
class_name MenuManager

@onready var pause_menu: Control = $PauseMenu
@onready var settings_menu: Control = $SettingsMenu
@onready var dead_menu: Control = $DeadMenu
@onready var win_menu: Control = $WinMenu


func _ready() -> void:
	hide_all_menu()
	
	UiManager.menu_stack_changed.connect(on_menu_changed)
	LevelManager.player_dead.connect(lost)
	LevelManager.player_win.connect(win)


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		var menu_size = UiManager.menu_stack.size()
		if menu_size == 0: # if no menu open
			UiManager.push_menu(pause_menu)
		else: # menu exist
			UiManager.pop_menu()



func hide_all_menu():
	var children = get_children()
	for child in children:
		child.hide()

func on_menu_changed(new_size: int):
	if new_size == 0:
		LevelManager.resume()
	
	if new_size == 1:
		LevelManager.pause()

func lost():
	LevelManager.pause()
	UiManager.push_menu(dead_menu)


func win(_score: int, _time: float):
	LevelManager.pause()
	UiManager.push_menu(win_menu)
