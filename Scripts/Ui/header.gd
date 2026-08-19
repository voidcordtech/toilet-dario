@tool
extends PanelContainer
class_name Header

@onready var title_text: Label = $MarginContainer/Title
@onready var close_icon_button: Button = $MarginContainer/CloseIconButton

@export var title: String = '[title]'

@export_tool_button('Set')
var set_title_button = set_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_text.text = str(title)
	close_icon_button.pressed.connect(on_close)


func on_close():
	UiManager.pop_menu()

func set_value() -> void:
	title_text.text = title
