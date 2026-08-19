extends Node
class_name HealthComponent

@export var max_health := 5
var health: int:
	set(value):
		health = value
		health_changed.emit(health)

signal dead
signal health_changed(new_health)

func _ready() -> void:
	health_changed.connect(check_health)
	health = max_health

func take_damage(value):
	health -= value

func check_health(value):
	if value <= 0:
		dead.emit()
