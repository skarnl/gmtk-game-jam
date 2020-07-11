extends Control


func _ready():
	var nodes = get_tree().get_nodes_in_group('player')
	nodes.front().connect('debug', self, '_on_Player_debug')


func _on_Player_debug(text):
	set_text(text)


func set_text(text):
	$RichTextLabel.text = text
