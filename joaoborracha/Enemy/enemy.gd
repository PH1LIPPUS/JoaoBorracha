extends CharacterBody2D


var vida_atual = 100
var vida_maxima = 100
var dano = 10 

func _on_area_2d_body_entered(body: Node2D) -> void:
	vida_atual -= dano
	vida_atual = clamp(vida_atual, 0, vida_maxima)  
	print(vida_atual)
	if vida_atual <= 0:
		queue_free()
