extends Node

func _ready():
	# Carrega a imagem original
	var original_image = preload("res://Resources/resources/sprites/Mira.png").get_image()
	
	# Redimensiona a imagem
	original_image.resize(70, 70, Image.INTERPOLATE_LANCZOS)
	
	# Cria uma nova textura com o tamanho ajustado
	var resized_texture = ImageTexture.create_from_image(original_image)
	
	# Define o cursor
	Input.set_custom_mouse_cursor(resized_texture, Input.CURSOR_ARROW, Vector2(16, 16))  # Hotspot no centro
