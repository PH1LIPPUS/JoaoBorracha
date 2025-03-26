extends Control



func _on_start_pressed() -> void:
	print("aaa")
	get_tree().change_scene_to_file("res://Sceens/cutsceen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
