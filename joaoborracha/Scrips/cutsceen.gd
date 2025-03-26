extends Control

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var main_label: Label = $Label
var story_parts := [
	"João Borracha encontra",
	"a sua mulher desaparecida,",
	"e uma nota do seu chefe.",
	"Isto é a história da sua vingança."
]

var current_part := 0
var skip_requested := false
var fade_duration := 3.0
var display_duration := 3.0  # Tempo que o texto fica totalmente visível antes do fade

func _ready() -> void:
	anim.play("idle")
	main_label.visible = false
	_start_fade_sequence()

func _start_fade_sequence():
	if skip_requested or current_part >= story_parts.size():
		get_tree().change_scene_to_file("res://Sceens/game.tscn")
		return

	# Configuração do label
	main_label.text = story_parts[current_part]
	main_label.add_theme_font_size_override("font_size", 44)
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	main_label.add_theme_constant_override("line_spacing", 12)
	

	# Animação
	main_label.visible = true
	main_label.modulate.a = 0.0  
	
	var tween = create_tween()
	# Fade in
	tween.tween_property(main_label, "modulate:a", 1.0, 1.0)
	# Mantém visível
	tween.tween_interval(display_duration)
	# Fade out
	tween.tween_property(main_label, "modulate:a", 0.0, fade_duration)
	
	await tween.finished
	current_part += 1
	_start_fade_sequence()

func _on_skip_pressed() -> void:
	skip_requested = true
	get_tree().change_scene_to_file("res://Sceens/game.tscn")

func _on_skip_mouse_entered() -> void:
	anim.play("skip")

func _on_skip_mouse_exited() -> void:
	anim.play("idle")
