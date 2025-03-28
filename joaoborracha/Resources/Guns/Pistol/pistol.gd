extends RigidBody2D

var being_held = false
var holder: Node2D = null
var flip_offset: Vector2 = Vector2(15, 0)  # Offset padrão
var normal_offset: Vector2 = Vector2(15, 0)  # Offset quando não está invertido

func _on_picked_up():
	being_held = true
	set_collision_layer_value(1, false)  # Desativa colisão
	set_collision_mask_value(1, false)
	freeze = true
	holder = get_parent()  # RightHand/Marker2D

func _process(delta):
	if being_held and holder:
		# Segue a posição global da mão
		global_position = holder.global_position
		global_rotation = holder.global_rotation
		
		# Verifica se o player está virado usando o holder hierarchy
		if holder.has_node("../player"):  # Verifica se existe um nó player no parent
			var player = holder.get_node("../player")
			if player is AnimatedSprite2D:
				if player.flip_h:
					position = Vector2(-15, 0)  # Offset quando virado
					scale.y = -1
				else:
					position = normal_offset
					scale.y = 1

func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Arma pode ser pega pelo player")
