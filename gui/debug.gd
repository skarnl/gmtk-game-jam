extends Control


func _ready():
	hide()


func set_text(text):
	$RichTextLabel.text = text
