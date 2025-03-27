extends Area2D


var inareawp= false

	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("weapon"):
		inareawp= false
		print("saiu")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("weapon") :
		inareawp= true
		print("entrou")
