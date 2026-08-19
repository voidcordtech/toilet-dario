extends Resource
class_name SfxStats

@export var streams: Array[AudioStream] = []
@export var volume_db: float = 0.0
@export var pitch: float = 1.0
@export var pitch_variation: float = 0.15
@export var bus: StringName = &"SFX"	
@export var max_distance: float = 40.0        # useful for 3D
@export var unit_size: float = 10.0           # useful for 3D
