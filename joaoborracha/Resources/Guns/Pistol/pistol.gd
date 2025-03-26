extends RigidBody2D




func _on_colisão_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") :
		print("aaa")
