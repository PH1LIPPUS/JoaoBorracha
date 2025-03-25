extends Control

@onready var label = $Label

func _ready():
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 20.0)
	await get_tree().create_timer(20.0).timeout
	get_tree().change_scene_to_file("res://Scene/game.tscn")

func _on_skip_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/game.tscn")
