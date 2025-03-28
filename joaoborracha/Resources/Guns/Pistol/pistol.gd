extends RigidBody2D

var being_held = false
var holder: Node2D = null
var normal_offset: Vector2 = Vector2(15, 0)  # Offset padrão (direita)
var flipped_offset: Vector2 = Vector2(-15, 0)  # Offset quando virado (esquerda)

func _on_picked_up():
	being_held = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	freeze = true
	holder = get_parent()  # RightHand/Marker2D

func _process(delta):
	if being_held and holder:
		# Acessa o sprite do player de forma segura
		var player_sprite = get_tree().get_nodes_in_group("player_sprite")
		if player_sprite.size() > 0:
			var sprite = player_sprite[0] as AnimatedSprite2D
			if sprite:
				# Ajusta posição e escala baseado na direção
				if sprite.flip_h:  # Virado para esquerda
					position = flipped_offset
					scale.y = 1  # Mantém a escala normal (não inverte verticalmente)
					rotation_degrees = 180  # Rotaciona 180 graus horizontalmente
				else:  # Virado para direita
					position = normal_offset
					scale.y = 1
					rotation_degrees = 0
		
		# Mantém a arma alinhada com a mão
		global_position = holder.global_position
		global_rotation = holder.global_rotation

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Arma pode ser pega pelo player")
