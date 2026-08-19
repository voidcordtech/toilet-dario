extends Area3D
class_name InteractableBox

@onready var e: Sprite3D = $E


@export var can_interact := true
var active := false
var interact_target: Node3D

signal interact(body: Player)


func _ready() -> void:
	if !can_interact:
		monitorable = false
		monitoring = false
	
	interact.connect(on_interact)
	set_active(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('interact'):
		# Interact 
		interact.emit(interact_target)



func set_can_interact(value: bool): 
	can_interact = value
	
	if can_interact:
		monitoring = true
		monitorable = true
	else:
		monitoring = false
		monitorable = false


func set_active(value: bool):
	active = value
	
	if active:
		e.show()
		set_process_unhandled_input(true)
	elif !active:
		e.hide()
		set_process_unhandled_input(false)


func on_interact(_body: Player):
	set_active(false)



func _on_body_entered(body: Node3D) -> void:
	interact_target = body
	set_active(true)


func _on_body_exited(_body: Node3D) -> void:
	interact_target = null
	set_active(false)
