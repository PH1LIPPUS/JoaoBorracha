extends Control

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _on_skip_pressed() -> void:
	get_tree().change_scene_to_file("res://Sceens/game.tscn")

func _on_skip_mouse_entered() -> void:
	anim.play("skip")

func _on_skip_mouse_exited() -> void:
	anim.play("idle")
