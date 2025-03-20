extends Node

# Referência ao nó do menu de pausa
@onready var menu = $Menupausa

func _ready():
	# Esconde o menu no início do jogo
	menu.visible = false

func _input(event):
	# Verifica se a tecla Esc foi pressionada
	if event.is_action_pressed("ui_cancel"):
		# Alterna a visibilidade do menu
		menu.visible = !menu.visible
		# Pausa ou despausa o jogo
		get_tree().paused = menu.visible

func _on_resume_pressed() -> void:
	menu.visible = false
	get_tree().paused = false

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main.tscn")
