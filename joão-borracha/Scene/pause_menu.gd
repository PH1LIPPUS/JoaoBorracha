extends CanvasLayer

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):  
		toggle_pause()

func _on_resume_pressed() -> void:
	print("a")
	toggle_pause()
	
func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = !visible



func _on_back_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/main.tscn")
