extends Node2D




func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Sceens/main.tscn")

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://Sceens/game.tscn")
