extends CanvasLayer

@onready var anim: AnimatedSprite2D = $MenuDuranteJogo

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):  
		toggle_pause()

func _on_resume_pressed() -> void:
	toggle_pause()
	
func toggle_pause():
	get_tree().paused = !get_tree().paused
	visible = !visible



func _on_back_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/main.tscn")


func _on_resume_mouse_entered() -> void:
	anim.play("resume")


func _on_resume_mouse_exited() -> void:
		anim.play("idle")


func _on_back_mouse_entered() -> void:
	anim.play("back")


func _on_back_mouse_exited() -> void:
		anim.play("idle")
