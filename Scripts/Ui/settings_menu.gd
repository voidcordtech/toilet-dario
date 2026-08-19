extends Control

@onready var scaling: OptionButton = %Scaling
@onready var fps: OptionButton = %Fps

@onready var master_volume: HSlider = %MasterVolume
@onready var sfx_volume: HSlider = %SfxVolume
@onready var ambient_volume: HSlider = %AmbientVolume

@onready var reset_button: Button = %ResetButton

const RENDER_SCALE: Array[float] = [1.0, 0.75, 0.5, 0.2]
const MAX_FPS: Array[int] = [0, 60, 30]

func _ready() -> void:
	scaling.item_selected.connect(set_scaling)
	fps.item_selected.connect(set_max_fps)

	master_volume.value_changed.connect(set_master_volume)
	sfx_volume.value_changed.connect(set_sfx_volume)
	ambient_volume.value_changed.connect(set_ambient_volume)
	
	reset_button.pressed.connect(set_default_value)
	
	''' Init '''
	set_default_value()

# Video 
func set_scaling(index: int = 0) -> void:
	scaling.select(index)
	get_viewport().scaling_3d_scale = RENDER_SCALE[index]

func set_max_fps(index: int = 0):
	fps.select(index)
	Engine.max_fps = MAX_FPS[index]

# Audio
func set_master_volume(value: float = 1):
	AudioServer.set_bus_volume_linear(0, value)
	master_volume.value = value

func set_sfx_volume(value: float = 1):
	AudioServer.set_bus_volume_linear(1, value)
	sfx_volume.value = value

func set_ambient_volume(value: float = 1):
	AudioServer.set_bus_volume_linear(2, value)
	ambient_volume.value = value

func set_default_value():
	# Video
	set_scaling()
	set_max_fps()
	# Audio
	set_master_volume()
	set_sfx_volume()
	set_ambient_volume()
