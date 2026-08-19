extends Node

var menu_stack: Array[Control] = []
signal menu_stack_changed(new_size: int)

func push_menu(new_menu: Control):
	if menu_stack.size() > 0:
		menu_stack.back().hide()
	menu_stack.push_back(new_menu)
	new_menu.show()
	new_menu.grab_focus()
	
	menu_stack_changed.emit(menu_stack.size())

func pop_menu():
	if menu_stack.size() > 0:
		menu_stack.pop_back().hide()
		
	if menu_stack.size() > 0: # if still have previous menu
		var previous = menu_stack.back()
		previous.show()
		previous.grab_focus()
	
	menu_stack_changed.emit(menu_stack.size())
