extends Area2D

@export var vida_restaurada: int = 1  

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":  
		
		if body.has_method("receber_cura"):
			body.receber_cura(vida_restaurada)
			queue_free()
