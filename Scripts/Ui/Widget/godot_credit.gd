extends RichTextLabel


func _ready() -> void:
	bbcode_enabled = true
	meta_clicked.connect(on_link_click)
	
	text = "This game uses [url=https://godotengine.org]Godot Engine[/url], available under the following license: [url=https://godotengine.org/license]https://godotengine.org/license[/url]"

func on_link_click(meta: Variant):
	OS.shell_open(str(meta))
