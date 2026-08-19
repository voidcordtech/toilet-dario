extends Node3D
class_name Level



var time: float

func _ready() -> void:
	time = 0


func _process(delta: float) -> void:
	time += delta
