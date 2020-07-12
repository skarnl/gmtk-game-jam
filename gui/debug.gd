extends Control


func _ready():
	if not OS.is_debug_build():
		hide()


func set_text(text):
	$RichTextLabel.text = text
