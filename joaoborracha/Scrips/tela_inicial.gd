extends Control

@onready var sair: AnimatedSprite2D = $Sair
@onready var play: AnimatedSprite2D = $Play


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://Sceens/cutsceen.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_mouse_entered() -> void:
	play.play("idle")

func _on_start_mouse_exited() -> void:
	play.play("sair")


func _on_quit_mouse_entered() -> void:
	sair.play("idle")


func _on_quit_mouse_exited() -> void:
	sair.play("sair")
