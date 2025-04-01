extends Node

@onready var fora = $Fora
@onready var dentro = $Dentro

func _ready():
	var original_image = preload("res://Resources/resources/sprites/Mira.png").get_image()
	original_image.resize(80, 80, Image.INTERPOLATE_LANCZOS)
	
	var resized_texture = ImageTexture.create_from_image(original_image)
	
	Input.set_custom_mouse_cursor(resized_texture, Input.CURSOR_ARROW, Vector2(16, 16))  # Hotspot no centro


func _on_preto_body_entered(body: Node2D) -> void:
	dentro.visible = true
	fora.visible = false

func _on_preto_body_exited(body: Node2D) -> void:
	dentro.visible = false
	fora.visible = true
