extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/cutseen.tscn") # Change to your cutscene scene path

func _on_quit_pressed() -> void:
	get_tree().quit() # Closes the game
