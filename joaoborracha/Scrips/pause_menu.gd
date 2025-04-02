extends CanvasLayer
@onready var res: AnimatedSprite2D = $PausePanel/resume
@onready var back: AnimatedSprite2D = $PausePanel/back

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
	get_tree().change_scene_to_file("res://Sceens/main.tscn")


func _on_resume_mouse_entered() -> void:
	res.play("resume")


func _on_resume_mouse_exited() -> void:
		res.play("idle")


func _on_back_mouse_entered() -> void:
	back.play("back")


func _on_back_mouse_exited() -> void:
		back.play("idle")
