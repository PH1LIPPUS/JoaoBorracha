extends Area2D

@export var inareawp = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("weapon") :
		inareawp= true
		print("entrou")


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("weapon"):
		inareawp= false
		print("saiu")
