extends Control


const youtube = 'https://www.youtube.com/@voidcordtech'
const source_code = 'https://github.com/voidcordtech/toilet-dario'


func _on_source_code_pressed() -> void:
	OS.shell_open(source_code)


func _on_youtube_pressed() -> void:
	OS.shell_open(youtube)




func _on_youtube_link_meta_clicked(meta: Variant) -> void:
	DisplayServer.clipboard_set(str(meta))


func _on_github_link_meta_clicked(meta: Variant) -> void:
	DisplayServer.clipboard_set(str(meta))
