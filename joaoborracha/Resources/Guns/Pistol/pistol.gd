extends RigidBody2D


func _on_picked_up():
	print("A arma foi agarrada")



func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") :
		print("O player passou por cima")
