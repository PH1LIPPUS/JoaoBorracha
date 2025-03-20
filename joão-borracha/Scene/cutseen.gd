extends Control


func _on_skip_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/menu.tscn")
